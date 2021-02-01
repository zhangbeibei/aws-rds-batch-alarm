# RDS批量监控报警和通知

## 背景介绍
目前利用 CloudWatch 针对 RDS 创建批量报警主要有两种方式，一种是针对每一个RDS实例创建单独的警报，这种方式问题在于每一个RDS都需要手动创建警报比较麻烦，另一种方式是跨所有 RDS 创建警报，这种方式问题在于只能监控所有数据库实例的统计指标，比如监控平均CPU利用率，最大CPU利用率等，但是收到的报警邮件中并不会说明具体的 RDS 实例的指标。
为了解决现有方式存在的问题，本文以CPU利用率指标为例，提供了一种批量创建RDS报警的脚本方案，可以解决以下场景：

1. 对于已有RDS数据库，可以通过脚本自动为每一个RDS实例创建CPU利用率的报警和通知
2. 新创建的RDS数据库会自动触发产生新的报警和通知
3. 自定义报警通知的邮箱

## 方法概要
本脚本实现的 RDS 批量报警功能方式如下图所示：
[Image: rds-batch-alarm.png]
1. 创建 “RDS DB instance event” 的CloudWatch Rule，触发CloudWatch Event，一旦有RDS数据库实例产生就会触发 CloudWatch Event 事件；
2. 创建 Lambda 函数，以 CloudWatch Event 作为 trigger，一旦有RDS数据库实例存在或产生，就会自动触发 Lambda 函数；
3. 在 Lambda 函数中以“CPU利用率”为示例指标创建 CloudWatch Alarm；
4. CloudWatch Alarm 中配置 AWS SNS topic，实现一旦有RDS CPU利用率超过Alarm值，就触发邮件报警。

## 部署步骤

1.设置AWS CLI Config
参考：https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html

2.下载并运行脚本

`git clone https://github.com/zhangbeibei/aws-rds-batch-alarm.git`

`cd aws-rds-batch-alarm`

`./deploy your_email_address[required] targat_region[option]`

3.前往电子邮件确认订阅 AWS SNS 

## 参考资料
AWS CloudWatch Event 文档：https://docs.aws.amazon.com/zh_cn/AmazonCloudWatch/latest/events/WhatIsCloudWatchEvents.html
获取 Amazon RDS 的 CloudWatch Events 和 Amazon EventBridge 事件：https://docs.aws.amazon.com/zh_cn/AmazonRDS/latest/UserGuide/rds-cloud-watch-events.html
AWS SNS 文档：https://docs.aws.amazon.com/zh_cn/sns/latest/dg/welcome.html (https://docs.aws.amazon.com/sns/index.html)
AWS Lambda 文档：https://docs.aws.amazon.com/zh_cn/lambda/latest/dg/welcome.html

