EUI Building System On Docker 
====================================================

利用Docker构建EUI各项手机工程，隔离各版本的环境依赖

Requirement
----------

1. 安装`Docker`并且配置为允许运行`非root`账号运行 
2. 将工程下的bin目录加入`PATH`环境变量中 
3. 当前用户的ssh公钥添加到diana对应账号的ssh key中 

Issues
------
未发现

Tested
------

* Android Marshmallow `x3 mainline` , `x2 mainline`
* Android Nougat `android-7.0.0_r14`

