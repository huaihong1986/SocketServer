//
//  ViewController.m
//  SocketServer
//
//  Created by Hu Aihong on 15-8-21.
//  Copyright (c) 2015年 ChinaCloud. All rights reserved.
//
#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController
@synthesize listener,connectionSockets;
@synthesize message,ReceiveData;
bool isRunning = NO;//判断当前socket是否已经开始监听socket请求

-(void) sendMessage
{
    if(!isRunning)
    {
        NSError *error = nil;
        if (![listener acceptOnPort:8080 error:&error]) {
            return;
        }
        NSLog(@"开始监听");
        isRunning = YES;
    }
    else
    {
        NSLog(@"重新监听");
        [listener disconnect];
        for (int i = 0; i < [connectionSockets count]; i++) {
            [[connectionSockets objectAtIndex:i]disconnect];
        }
        isRunning = FALSE;
    }
}
- (IBAction)sendMessage:(id)sender
{
    if(![message.text isEqual:@""])
    {
        [(AsyncSocket *)[connectionSockets objectAtIndex:0] writeData:[message.text dataUsingEncoding:NSUTF8StringEncoding]
                withTimeout:-1 tag:1];
        
    }
    else
    {
        UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:@"Waring"message:@"Please Input Message"delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil,nil];
        
        [alertView show];
       
    }
}
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if([textField tag]==1)
    {
        [self viewUp];
    }
}
//click return button,then keyboard disappear
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    [self viewDown];
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [message resignFirstResponder];
    
     [self viewDown];
}

- (void) viewUp
{
    CGRect frame=self.view.frame;
    frame.origin.y=frame.origin.y-215;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.view.frame=frame;
    [UIView commitAnimations];
}
- (void) viewDown
{
    CGRect frame=self.view.frame;
    frame.origin.y=frame.origin.y+215;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.view.frame=frame;
    [UIView commitAnimations];
}
- (void)viewDidLoad
{
    ReceiveData.editable=NO;//设置TextView不可以编辑
    listener=[[AsyncSocket alloc]initWithDelegate:self];
     [message setTag:1];
    self.message.delegate=self;
    //初始化连接socket的个数
    connectionSockets=[[NSMutableArray alloc]initWithCapacity:30];
    isFirst = YES;
    [self sendMessage];
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


#pragma socket委托
//连接socket出错时调用
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"%@",[err description]);
}
//收到新的socket连接时调用
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    //将连接服务的客户端记录起来,以便以后实现客户端通信时使用
    [connectionSockets addObject:newSocket];
}
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [sock readDataWithTimeout: -1 tag: 0];
}
//与服务器建立连接时调用(连接成功)
- (void) onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    //这里的host就是当前进行服务器连接的客户端ip
    NSLog(@"host:%@",host);
    NSString *returnMessage=@"Welcome To Socket Test Server!";
    //将NSString转换成为NSData类型
    NSData *data=[returnMessage dataUsingEncoding:NSUTF8StringEncoding];
    //向当前连接服务器的客户端发送连接成功信息
    [sock writeData:data withTimeout:-1 tag:0];
}
/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 读取客户端发送来的信息(收到socket信息时调用)
 **/

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *msg = [[NSString alloc]initWithData: data encoding:NSUTF8StringEncoding];
    NSLog(@"NowReceive Message:%@",msg);
    //获取当前发送消息的客户端ip
    //NSLog(@"%@",sock.connectedHost);
    //NSString *ClientIp=[sock connectedHost];
    NSString *receviceIp=nil;
    
    //从所有连接的客户端当中遍历要接收信息的客户端
    for(int i=0;i<[connectionSockets count];i++)
    {
        AsyncSocket *s=(AsyncSocket*)[connectionSockets objectAtIndex:i];
        
        //这里要说明一下,在想另外一个客户端发送信息时需要指定客户端ip地址,所以在发送消息的时候,应该将ip地址一并写在消息里面,然后由服务端进行处理,我这里这是做了一个简单的Demo,有2个客户端相互发送消息
        
        if([sock.connectedHost isEqualToString:@"10.9.93.122"])
        {
            receviceIp=@"10.9.93.122";
        }
     
        if([s.connectedHost isEqualToString:receviceIp])
        {
            //[s writeData:data withTimeout:-1 tag:0];
            if(msg)
            {
                ReceiveData.text = msg;
                NSLog(@"Receive Message:%@",msg);
            }
            else
            {
                NSLog(@"Error converting received data into UTF-8 String");
            }
        }
        else
        {
            //如果遍历不存在,则说明客户端为进行连接
            NSString *returnMes=@"对方不在线!";
            NSData *datareturn=[returnMes dataUsingEncoding:NSUTF8StringEncoding];
            [sock writeData:datareturn withTimeout:-1 tag:0];
        }
    }
    
}
- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    [connectionSockets removeObject:sock];
}

#pragma end Deleagte

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    ReceiveData=nil;
    message=nil;
    
   
}
@end
