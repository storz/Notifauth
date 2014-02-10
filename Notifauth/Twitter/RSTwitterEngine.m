//
//  RSTwitterEngine.m
//  RSOAuthEngine
//
//  Created by Rodrigo Sieiro on 12/8/11.
//  Copyright (c) 2011-2020 Rodrigo Sieiro <rsieiro@sharpcube.com>. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "RSTwitterEngine.h"

// Never share this information
#define TW_CONSUMER_KEY @""
#define TW_CONSUMER_SECRET @""

// This will be called after the user authorizes your app
#define TW_CALLBACK_URL @"rstwitterengine://auth_token"

// Default twitter hostname and paths
#define TW_HOSTNAME @"api.twitter.com"
#define TW_REQUEST_TOKEN @"oauth/request_token"
#define TW_ACCESS_TOKEN @"oauth/access_token"
#define TW_STATUS_UPDATE @"1.1/statuses/update.json"
#define TW_GET_USER_TIMELINE @"1.1/statuses/user_timeline.json"
#define TW_GET_FAVORITES @"1.1/favorites/list.json"

// URL to redirect the user for authentication
#define TW_AUTHORIZE(__TOKEN__) [NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", __TOKEN__]

@interface RSTwitterEngine ()

- (void)removeOAuthTokenFromKeychain;
- (void)storeOAuthTokenInKeychain;
- (void)retrieveOAuthTokenFromKeychain;

@end

@implementation RSTwitterEngine

#pragma mark - Read-only Properties

- (NSString *)screenName
{
    return _screenName;
}

#pragma mark - Initialization

- (id)initWithDelegate:(id <RSTwitterEngineDelegate>)delegate
{
    self = [super initWithHostName:TW_HOSTNAME
                customHeaderFields:nil
                   signatureMethod:RSOAuthHMAC_SHA1
                       consumerKey:TW_CONSUMER_KEY
                    consumerSecret:TW_CONSUMER_SECRET 
                       callbackURL:TW_CALLBACK_URL];
    
    if (self) {
        _oAuthCompletionBlock = nil;
        _screenName = nil;
        self.delegate = delegate;
        
        // Retrieve OAuth access token (if previously stored)
        [self retrieveOAuthTokenFromKeychain];
    }
    
    return self;
}

#pragma mark - OAuth Access Token store/retrieve

- (void)removeOAuthTokenFromKeychain
{
    // Build the keychain query
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          (__bridge_transfer NSString *)kSecClassGenericPassword, (__bridge_transfer NSString *)kSecClass,
                                          self.consumerKey, kSecAttrService,
                                          self.consumerKey, kSecAttrAccount,
                                          kCFBooleanTrue, kSecReturnAttributes,
                                          nil];
    
    // If there's a token stored for this user, delete it
    CFDictionaryRef query = (__bridge_retained CFDictionaryRef) keychainQuery;
    SecItemDelete(query);
    CFRelease(query);
}

- (void)storeOAuthTokenInKeychain
{
    // Build the keychain query
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          (__bridge_transfer NSString *)kSecClassGenericPassword, (__bridge_transfer NSString *)kSecClass,
                                          self.consumerKey, kSecAttrService,
                                          self.consumerKey, kSecAttrAccount,
                                          kCFBooleanTrue, kSecReturnAttributes,
                                          nil];
    
    CFTypeRef resData = NULL;
    
    // If there's a token stored for this user, delete it first
    CFDictionaryRef query = (__bridge_retained CFDictionaryRef) keychainQuery;
    SecItemDelete(query);
    CFRelease(query);
    
    // Build the token dictionary
    NSMutableDictionary *tokenDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            self.token, @"oauth_token",
                                            self.tokenSecret, @"oauth_token_secret",
                                            self.screenName, @"screen_name",
                                            nil];
    
    // Add the token dictionary to the query
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:tokenDictionary] 
                      forKey:(__bridge_transfer NSString *)kSecValueData];
    
    // Add the token data to the keychain
    // Even if we never use resData, replacing with NULL in the call throws EXC_BAD_ACCESS
    query = (__bridge_retained CFDictionaryRef) keychainQuery;
    SecItemAdd(query, (CFTypeRef *) &resData);
    CFRelease(query);
}

- (void)retrieveOAuthTokenFromKeychain
{
    // Build the keychain query
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          (__bridge_transfer NSString *)kSecClassGenericPassword, (__bridge_transfer NSString *)kSecClass,
                                          self.consumerKey, kSecAttrService,
                                          self.consumerKey, kSecAttrAccount,
                                          kCFBooleanTrue, kSecReturnData,
                                          kSecMatchLimitOne, kSecMatchLimit,
                                          nil];
    
    // Get the token data from the keychain
    CFTypeRef resData = NULL;
    
    // Get the token dictionary from the keychain
    CFDictionaryRef query = (__bridge_retained CFDictionaryRef) keychainQuery;
    
    if (SecItemCopyMatching(query, (CFTypeRef *) &resData) == noErr)
    {
        NSData *resultData = (__bridge_transfer NSData *)resData;
        
        if (resultData)
        {
            NSMutableDictionary *tokenDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:resultData];
            
            if (tokenDictionary) {
                [self setAccessToken:[tokenDictionary objectForKey:@"oauth_token"]
                              secret:[tokenDictionary objectForKey:@"oauth_token_secret"]];
                
                _screenName = [tokenDictionary objectForKey:@"screen_name"];
            }
        }
    }
    
    CFRelease(query);
}

#pragma mark - OAuth Authentication Flow

- (void)authenticateWithCompletionBlock:(RSTwitterEngineCompletionBlock)completionBlock
{
    // Store the Completion Block to call after Authenticated
    _oAuthCompletionBlock = [completionBlock copy];
    
    // First we reset the OAuth token, so we won't send previous tokens in the request
    [self resetOAuthToken];
    
    // OAuth Step 1 - Obtain a request token
    MKNetworkOperation *op = [self operationWithPath:TW_REQUEST_TOKEN
                                              params:nil
                                          httpMethod:@"POST"
                                                 ssl:YES];

    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        // Fill the request token with the returned data
        [self fillTokenWithResponseBody:[completedOperation responseString] type:RSOAuthRequestToken];
        
        // OAuth Step 2 - Redirect user to authorization page
        [self.delegate twitterEngine:self statusUpdate:@"Waiting for user authorization..."];
        NSURL *url = [NSURL URLWithString:TW_AUTHORIZE(self.token)];
        [self.delegate twitterEngine:self needsToOpenURL:url];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error);
        _oAuthCompletionBlock = nil;
    }];
    
    [self.delegate twitterEngine:self statusUpdate:@"Requesting Tokens..."];
    [self enqueueSignedOperation:op];
}

- (void)resumeAuthenticationFlowWithURL:(NSURL *)url
{
    // Fill the request token with data returned in the callback URL
    [self fillTokenWithResponseBody:url.query type:RSOAuthRequestToken];
    // OAuth Step 3 - Exchange the request token with an access token
    MKNetworkOperation *op = [self operationWithPath:TW_ACCESS_TOKEN
                                              params:nil
                                          httpMethod:@"POST"
                                                 ssl:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        // Fill the access token with the returned data
        [self fillTokenWithResponseBody:[completedOperation responseString] type:RSOAuthAccessToken];
        
        // Retrieve the user's screen name
        _screenName = [self customValueForKey:@"screen_name"];
        
        // Store the OAuth access token
        [self storeOAuthTokenInKeychain];
		[self.delegate twitterEngine:self statusUpdate:[NSString stringWithFormat:@"%@", _screenName]];
        
        // Finished, return to previous method
        if (_oAuthCompletionBlock) _oAuthCompletionBlock(nil);
        _oAuthCompletionBlock = nil;
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
        _oAuthCompletionBlock = nil;
    }];

    [self.delegate twitterEngine:self statusUpdate:@"Authenticating..."];
    [self enqueueSignedOperation:op];
}

- (void)cancelAuthentication
{
    NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Authentication cancelled.", NSLocalizedDescriptionKey, nil];
    NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSTwitterEngine.ErrorDomain" code:401 userInfo:ui];
    
    if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
    _oAuthCompletionBlock = nil;
}

- (void)forgetStoredToken
{
    [self removeOAuthTokenFromKeychain];
    
    [self resetOAuthToken];
    _screenName = nil;
}

#pragma mark - Public Methods

- (void)getMyTimeline:(RSTwitterEngineCompletionBlockWithResult)completionBlock
			withCount:(int)count
			   before:(NSString*)maxIdString {
    if (!self.isAuthenticated) {
        [self authenticateWithCompletionBlock:^(NSError *error) {
            if (error) {
                completionBlock(error, nil);
            } else {
                [self getFavorites:completionBlock];
            }
        }];
        return;
    }
	
	NSMutableDictionary *getParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%d", count], @"count",
									  @"false", @"include_rts",
									  nil];
	if (![maxIdString isEqualToString:@""]) {
		[getParams setObject:[NSString stringWithFormat:@"%lld", [maxIdString longLongValue] - 1]
					  forKey:@"max_id"];
	}
    MKNetworkOperation *op = [self operationWithPath:TW_GET_USER_TIMELINE
                                              params:getParams
                                          httpMethod:@"GET"
                                                 ssl:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        completionBlock(nil, [completedOperation.responseData copy]);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    [self enqueueSignedOperation:op];
}

- (void)getFavorites:(RSTwitterEngineCompletionBlockWithResult)completionBlock {
    if (!self.isAuthenticated) {
        [self authenticateWithCompletionBlock:^(NSError *error) {
            if (error) {
                completionBlock(error, nil);
            } else {
                [self getFavorites:completionBlock];
            }
        }];
        return;
    }
	
	NSMutableDictionary *getParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   @"50", @"count",
                                       nil];
    MKNetworkOperation *op = [self operationWithPath:TW_GET_FAVORITES
                                              params:getParams
                                          httpMethod:@"GET"
                                                 ssl:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        completionBlock(nil, [completedOperation.responseData copy]);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    [self enqueueSignedOperation:op];
}

@end
