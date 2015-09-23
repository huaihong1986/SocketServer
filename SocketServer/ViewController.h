//
//  ViewController.h
//  SocketServer
//
//  Created by Hu Aihong on 15-8-21.
//  Copyright (c) 2015年 ChinaCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncSocket.h"
@interface ViewController : UIViewController
<AsyncSocketDelegate,UITextFieldDelegate>
{
    
    BOOL isFirst;
    
   
}

@property (nonatomic, retain)AsyncSocket *listener;
@property (nonatomic, retain)IBOutlet UITextField *message;
@property (nonatomic, retain)IBOutlet UITextView *ReceiveData;
@property (nonatomic) AsyncSocket *listener;//监听客户端请求
//AsyncUdpSocket *udpSocket;//不需要即时连接就能通讯
@property (nonatomic) NSMutableArray *connectionSockets;//当前请求连接的客户端
- (IBAction)sendMessage:(id)sender;
- (IBAction)textEndEditting:(id)sender;

@end