//
//  CallListCell.m
//  VKTemplateForiPhone
//
//  Created by NPHD on 15/7/27.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "CallListCell.h"

@implementation CallListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellDataInfo:(NSDictionary *)dataInfo {
    
     [super setCellDataInfo:dataInfo];
    
    menuLabel.text = getString([dataInfo objectForKey:@"consume_no"]);
    statusBtn.enabled = ![[dataInfo objectForKey:@"phone_chart_status"] boolValue];//会话状态  0 进行中  1结束
    
    if (isValidString(getString([dataInfo objectForKey:@"doctor_cfg_time"]))) {
        apointmentTime.text = getString([dataInfo objectForKey:@"doctor_cfg_time"]);
    }

    if (isValidString(getString([dataInfo objectForKey:@"phone_start_time"]))) {
        starTime.text = getString([dataInfo objectForKey:@"phone_start_time"]);
    }
    if (isValidString(getString([dataInfo objectForKey:@"remain_time"]))) {
        NSString *endStr = getString([dataInfo objectForKey:@"remain_time"]);
        endTime.text = getString([NSString stringWithFormat:@"%@分钟",endStr]);
    }
    if (isValidString(getString([dataInfo objectForKey:@"pay_time"]))) {
        payTimeLabel.text = getString([dataInfo objectForKey:@"pay_time"]);
    }

    nickName.text = getString([dataInfo objectForKey:@"user_name"]);
    imageAvtar.layer.cornerRadius = imageAvtar.frame.size.width / 2.f;
    [imageAvtar setImageURLStr:[dataInfo objectForKey:@"photo"] placeholder:Defualt_Avatar_Image];
    
    _phoneCallId = getString([dataInfo objectForKey:@"phone_conversation_id"]);
    _converstationId = getString([dataInfo objectForKey:@"conversation_id"]);
    //进行中
    if ([[dataInfo objectForKey:@"phone_chart_status"] boolValue] ==0) {
        commentView.hidden = YES;
        chatAndCommentView.hidden = YES;
        lineView.hidden = NO;
        phoneView.hidden = NO;
        setViewFrameSizeHeight(underLineView, 15);
        underLineView.backgroundColor=GetColorWithRGB(241, 240, 238);
        setViewFrameSizeHeight(lineView, 0.5);
        lineView.backgroundColor=GetColorWithRGB(241, 240, 238);
        setViewFrameOriginY(phoneView,lineView.frame.origin.y +lineView.frame.size.height+3);
        setViewFrameOriginY(underLineView, phoneView.frame.size.height+phoneView.frame.origin.y+10);
        setViewFrameSizeHeight(self, underLineView.frame.origin.y+underLineView.frame.size.height);

    }
    //已经结束
    else
    {
        //已经结束，并且评论完
        if ([[dataInfo objectForKey:@"is_eval"] floatValue] == 1) {
            //显示评价
            chatAndCommentView.hidden = YES;
            phoneView.hidden = YES;
            commentView.hidden = NO;
            lineView.hidden = NO;
            commentLable.text = getString([dataInfo objectForKey:@"comment_msg"]);
            fitLabelHeight(commentLable, getString([dataInfo objectForKey:@"comment_msg"]));
            ratingView1.rating = [[dataInfo objectForKey:@"attitude_star"] integerValue];
            ratingView2.rating = [[dataInfo objectForKey:@"ability_star"] integerValue];
            ratingView1.userInteractionEnabled = NO;
            ratingView2.userInteractionEnabled = NO;
            setViewFrameOriginY(starView, commentLable.frame.size.height+commentLable.frame.origin.y+5);
            setViewFrameSizeHeight(commentView, starView.frame.size.height+starView.frame.origin.y);
            setViewFrameSizeHeight(self, commentView.frame.size.height+commentView.frame.origin.y);
            
            setViewFrameSizeHeight(lineView, 0.5);
            lineView.backgroundColor=GetColorWithRGB(241, 240, 238);
            
            setViewFrameSizeHeight(underLineView, 12);
            underLineView.backgroundColor=GetColorWithRGB(241, 240, 238);
            setViewFrameOriginY(underLineView, commentView.frame.size.height+commentView.frame.origin.y+10);
            setViewFrameSizeHeight(self, underLineView.frame.origin.y+underLineView.frame.size.height);
        }
        //已经结束，但是没有评论
       else
       {
           //显示图文咨询与可评价
           commentView.hidden = YES;
           phoneView.hidden = YES;
           chatAndCommentView.hidden = NO;
           if ([[dataInfo objectForKey:@"chart_status"] boolValue]) {
               chatBtn.enabled = YES;
           }
           else
           {
               chatBtn.hidden = NO;
           }
           lineView.hidden = NO;
           setViewFrameSizeHeight(underLineView, 15);
           underLineView.backgroundColor=GetColorWithRGB(241, 240, 238);
           setViewFrameSizeHeight(lineView, 0.5);
           lineView.backgroundColor=GetColorWithRGB(241, 240, 238);
           setViewFrameOriginY(chatAndCommentView,lineView.frame.origin.y +lineView.frame.size.height+3);
           setViewFrameOriginY(underLineView, chatAndCommentView.frame.size.height+chatAndCommentView.frame.origin.y+10);
           setViewFrameSizeHeight(self, underLineView.frame.origin.y+underLineView.frame.size.height);
       }

       
    }
}

- (IBAction)btnAction:(UIButton*)sender
{   
    if (sender.tag == 101) {
       
        if([_delegate respondsToSelector:@selector(setPhoneCallId:btnClickType:)])
        {
            [_delegate setPhoneCallId:_phoneCallId btnClickType:phoneCallBtnClick];
        }
    }
    else if (sender.tag == 102)
    {
        if([_delegate respondsToSelector:@selector(setPhoneCallId:btnClickType:)])
        {
            [_delegate setPhoneCallId:_converstationId btnClickType:chatBtnClick];
        }

    }
    else if (sender.tag == 103)
    {
        if([_delegate respondsToSelector:@selector(setPhoneCallId:btnClickType:)])
        {
            [_delegate setPhoneCallId:_phoneCallId btnClickType:commentBtnClick];
        }
    }
}

- (CGFloat)getCellHeight:(NSDictionary*)cInfo
{
    [self setCellDataInfo:cInfo];
    return self.frame.size.height;
}
@end
