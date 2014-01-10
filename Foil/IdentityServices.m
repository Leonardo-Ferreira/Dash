//
//  IdentityServices.m
//  Foil
//
//  Created by Leonardo Ferreira on 7/26/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "IdentityServices.h"

@implementation IdentityServices
{
    BOOL relevantTag;
    NSString *completeXML;
}
@synthesize validateAgainstURL;
@synthesize validationDone=_validationDone;
@synthesize userValidated=_userValidated;

-(void)validateCredentialsAsync:(NSString *)userName password:(NSString *)password{
    NSString *packageXML = [NSString stringWithFormat: @"{\"username\":\"%@\", \"password\":\"%@\"}", userName, password];
    NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
    [headers setObject:@"application/Json; charset=utf-8" forKey:@"content-type"];
    [headers setObject:[[NSURL URLWithString:validateAgainstURL] host] forKey:@"Host"];
    
    //192.168.245.205/hospitaleintegrationservices/corporativo.asmx
    [Util post:validateAgainstURL content:packageXML headers:headers successBlock:^(NSData *data, id jsonData){
        NSLog(@"Post Succeded");
        NSXMLParser *parser = [[NSXMLParser alloc]initWithData:data];
        parser.delegate = self;
        completeXML = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        [parser parse];
        NSLog(@"Parsing started. Wait for parsing events");
    } errorBlock:^(NSError *error){
        NSLog(@"Erro: %@",error);
    } completeBlock:^{
        _validationDone = YES;
        NSArray *auxT = [[[NetworkOperation getInstance] getToken] componentsSeparatedByString:@";"];
        _userValidated = [[auxT objectAtIndex:1] isEqual:@"True"];
        NSLog(@"validationDone = %s", _validationDone ? "true" : "false");
    }];
}

-(User *)getUserIdentity:(NSString *)userName{
    return  nil;
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    relevantTag = ([elementName caseInsensitiveCompare:@"VerificarUsuarioResult"] == NSOrderedSame);
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    NSLog(@"Parse Found Characters");
    if(relevantTag){
        _userValidated = [string boolValue];
        _validationDone = YES;
        NSLog(@"Validation Done");
    }
}
@end
