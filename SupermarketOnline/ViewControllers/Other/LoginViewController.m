//
//  LoginViewController.m
//  YMYL
//
//  Created by ljy on 15/8/21.
//  Copyright (c) 2015年 ljy. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>

@interface LoginViewController () <WXApiDelegate,TencentSessionDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    TencentOAuth *_tencentOAuth;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"登录";
//    UIButton *rightButn = [UIButton buttonWithType:UIButtonTypeCustom];
//    rightButn.frame = CGRectMake(0, 0, 60, 26);
//    rightButn.contentMode = UIViewContentModeScaleAspectFit;
//    rightButn.titleLabel.font = [UIFont systemFontOfSize:13];
//    [rightButn setTitle:@"忘记密码" forState:UIControlStateNormal];
//    [rightButn addTarget:self action:@selector(findPWD) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *rightBarButn = [[UIBarButtonItem alloc] initWithCustomView:rightButn];
//    self.navigationItem.rightBarButtonItem = rightBarButn;
    
    self.loginBtn.layer.cornerRadius = 5;
    self.loginBtn.layer.masksToBounds = YES;
    
    [self.phoneTF setLeftView:@"login_user" placeholder:@"昵称"];
    [self.passwordTF setLeftView:@"login_key" placeholder:@"密码"];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (! _hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    
    if (!_networkConditionHUD) {
        _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_networkConditionHUD];
    }
    _networkConditionHUD.mode = MBProgressHUDModeText;
    _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
    _networkConditionHUD.margin = HUDMargin;
}

- (IBAction)loginAction:(id)sender {
    [self.phoneTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    [self requestMemberLogin];
}
- (IBAction)weixinLoginAction:(id)sender {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:WeixinLogin object:nil];
    [self sendAuthRequest];
}

- (void)sendAuthRequest //发送微信登录接入请求
{
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact"; // @"post_timeline,sns"
    req.state = @"xxx";
    //    req.openID = @"0c806938e2413ce73eef92cc3";
    
    [WXApi sendAuthReq:req viewController:self delegate:self];
}

- (IBAction)qqLoginAction:(id)sender {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:QQLogin object:nil];
    [self sendTencentOAuth];
}

- (void)sendTencentOAuth {  //发送QQ授权登录
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:kShare_QQ_AppID andDelegate:self];
    NSArray *_permissions = [NSArray arrayWithObjects:@"get_user_info", nil];
    [_tencentOAuth authorize:_permissions];
}

//登录成功
- (void)tencentDidLogin
{
//    _labelTitle.text = @"登录完成";
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length])
    {
        // 记录登录用户的OpenID、Token以及过期时间
        [_tencentOAuth accessToken] ;
        [_tencentOAuth openId] ;
        NSMutableString *appendString = [NSMutableString stringWithFormat:@"https://graph.qq.com/user/get_user_info?access_token=%@&oauth_consumer_key=%@&openid=%@",[_tencentOAuth accessToken],kShare_QQ_AppID,[_tencentOAuth openId]];
        NSLog(@"appendString: %@",appendString);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.stringEncoding = NSUTF8StringEncoding;
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        manager.requestSerializer.timeoutInterval = 5;
        [manager GET:[appendString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"JSON_Userinfo: %@", responseObject);
            NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:QQLogin, @"op", nil];
            NSDictionary *paramsDic = [[NSDictionary alloc] initWithObjectsAndKeys:[_tencentOAuth openId],@"account",@"QQ",@"thirdParty",[responseObject objectForKey:@"nickname"],@"nickName",[_tencentOAuth accessToken],@"token", nil];
            [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(OtherLogin) delegate:self params:paramsDic info:infoDic];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    else
    {
        NSLog(@"登录不成功 没有获取accesstoken");
    }
}

//非网络错误导致登录失败：
-(void)tencentDidNotLogin:(BOOL)cancelled
{
//    if (cancelled)
//    {
//        _labelTitle.text = @"用户取消登录";
//    }
//    else
//    {
//        _labelTitle.text = @"登录失败";
//    }
}

//网络错误导致登录失败
-(void)tencentDidNotNetWork
{
//    _labelTitle.text=@"无网络连接，请设置网络";
}

- (IBAction)registerAction:(id)sender {
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.phoneTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
}


#pragma mark - 发送请求
-(void)requestMemberLogin { //登录
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:Login object:nil];
    
    NSString *mixStr = [NSString stringWithFormat:@"%@%@",@"jw134#%pqNLVfn",self.passwordTF.text];
    mixStr = [GlobalSetting md5HexDigest:mixStr];   //第一次加密
    NSString *pwdMD5 = [GlobalSetting md5HexDigest:mixStr];     //第二次加密
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:Login, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.phoneTF.text,@"nickName",pwdMD5,@"password", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(Login) delegate:nil params:pram info:infoDic];
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        if (!_networkConditionHUD) {
            _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:_networkConditionHUD];
        }
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        _networkConditionHUD.mode = MBProgressHUDModeText;
        _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
        _networkConditionHUD.margin = HUDMargin;
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    NSLog(@"_responseObject: %@",responseObject);
    
    if ([notification.name isEqualToString:Login]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:Login object:nil];
        if ([responseObject[@"result"] boolValue]) {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            NSDictionary *dic = responseObject[@"item"];
            [[GlobalSetting shareGlobalSettingInstance] setLoginPWD:self.passwordTF.text]; //存储登录密码
            [[GlobalSetting shareGlobalSettingInstance] setIsLogined:YES];  //已登录标示
            [[GlobalSetting shareGlobalSettingInstance] setUserID:[NSString stringWithFormat:@"%@",dic [@"id"]]];
            [[GlobalSetting shareGlobalSettingInstance] setToken:dic [@"token"]];
            [[GlobalSetting shareGlobalSettingInstance] setmName:dic [@"nickName"]];

            [self.navigationController popViewControllerAnimated:YES]; //返回登录页面
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    if ([notification.name isEqualToString:WeixinLogin]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:WeixinLogin object:nil];
        
        if ([responseObject[@"result"] boolValue]) {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            NSDictionary *dic = responseObject[@"item"];
            [[GlobalSetting shareGlobalSettingInstance] setIsLogined:YES];  //已登录标示
            [[GlobalSetting shareGlobalSettingInstance] setUserID:[NSString stringWithFormat:@"%@",dic [@"id"]]];
            [[GlobalSetting shareGlobalSettingInstance] setToken:dic [@"token"]];
            NSLog(@"nickName: %@",dic [@"nickName"]);
            [[GlobalSetting shareGlobalSettingInstance] setmName:dic [@"nickName"]];
            
            [self.navigationController popViewControllerAnimated:YES]; //返回登录页面
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    if ([notification.name isEqualToString:QQLogin]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:QQLogin object:nil];
        
        if ([responseObject[@"result"] boolValue]) {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            NSDictionary *dic = responseObject[@"item"];
            [[GlobalSetting shareGlobalSettingInstance] setIsLogined:YES];  //已登录标示
            [[GlobalSetting shareGlobalSettingInstance] setUserID:[NSString stringWithFormat:@"%@",dic [@"id"]]];
            [[GlobalSetting shareGlobalSettingInstance] setToken:dic [@"token"]];
            NSLog(@"nickName: %@",dic [@"nickName"]);
            [[GlobalSetting shareGlobalSettingInstance] setmName:dic [@"nickName"]];
            
            [self.navigationController popViewControllerAnimated:YES]; //返回登录页面
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
