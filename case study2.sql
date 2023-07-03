use operation;

/*Case Study 2 (Investigating metric spike)*/

/*User Engagement: To measure the activeness of a user. 
                   Measuring if the user finds quality in a product/service.
Your task: Calculate the weekly user engagement?*/

select extract(week from occurred_at) as num_week,
count(distinct user_id) as no_of_distinct_user 
from `table-3 email_events (1)`
group by num_week;


/*User Growth: Amount of users growing over time for a product.
Your task: Calculate the user growth for product?*/



select *,
new_user_activated-lag(new_user_activated) over( order by year_,quarter_ ) as user_growth
from(select year(created_at) as year_,quarter(created_at) as quarter_,count(user_id) as new_user_activated 
from`table-1 users`
where 
activated_at is not null 
group by 1)a ;


/*Weekly Retention: Users getting retained weekly after signing-up for a product.
Your task: Calculate the weekly retention of users-sign up cohort?*/

select count(user_id),
       sum(case when retention_week = 1 then 1 else 0 end) as per_week_retention
from
(
select a.user_id,
       a.sign_up_week,
       b.engagement_week,
       b.engagement_week - a.sign_up_week as retention_week
from
(
(select distinct user_id, extract(week from occured_at) as sign_up_week
from `table-3 email_events (1)`
where event_type = 'signup_flow'
and event_name = 'complete_signup'
and extract(week from occured_at)=18)a
left join
(select distinct user_id, extract(week from occured_at) as engagement_week
from `table-3 email_events (1)`
where event_type = 'engagement')b
on a.user_id = b.user_id
)
group by user_id
order by user_id;

/*Weekly Engagement: To measure the activeness of a user. 
                     Measuring if the user finds quality in a product/service weekly. 
Your task: Calculate the weekly engagement per device? */

select 
extract(year from occurred_at) as year_num,
extract(week from occurred_at) as week_num,
device,
count(distinct user_id) as no_of_users
from `table-2 events (1)`
where event_type = 'engagement'
group by 1,2,3
order by 1,2,3;

/*Email Engagement: Users engaging with the email service.
Your task: Calculate the email engagement metrics? */

select 
100.0 * sum(case when email_cat = 'email_opened' then 1 else 0 end)
        /sum(case when email_cat = 'email_sent' then 1 else 0 end)
as email_opening_rate,
100.0 * sum(case when email_cat = 'email_clicked' then 1 else 0 end)
        /sum(case when email_cat = 'email_sent' then 1 else 0 end)
as email_clicking_rate
from
(
select *,
case when action in ('sent_weekly_digest', 'sent_reengagement_email')
     then 'email_sent'
     when action in ('email_open')
     then 'email_opened'
     when action in ('email_clickthrough')
     then 'email_clicked'
end as email_cat
from `table-3 email_events (1)`
)a;