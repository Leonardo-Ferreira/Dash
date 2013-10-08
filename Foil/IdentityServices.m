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
    NSString *packageXML = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><VerificarUsuario xmlns=\"http://integrationservices.hospitale.aec.com.br/\"><pLogin>%@</pLogin><pSenha>%@</pSenha></VerificarUsuario></soap:Body></soap:Envelope>", userName, password];
    NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
    [headers setObject:@"text/xml; charset=utf-8" forKey:@"content-type"];
    [headers setObject:@"http://integrationservices.hospitale.aec.com.br/VerificarUsuario" forKey:@"SOAPAction"];
    [headers setObject:[[NSURL URLWithString:validateAgainstURL] host] forKey:@"Host"];
    
    //192.168.245.205/hospitaleintegrationservices/corporativo.asmx
    [Util post:validateAgainstURL content:packageXML headers:headers successBlock:^(NSData *data, id jsonData){
        NSLog(@"Post Succeded");
        NSXMLParser *parser = [[NSXMLParser alloc]initWithData:data];
        parser.delegate = self;
        completeXML = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        [parser parse];
        NSLog(@"Parsing started. Wait for parsing events");
    } errorBlock:^(NSError *error){} completeBlock:^{_validationDone=YES;}];
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
