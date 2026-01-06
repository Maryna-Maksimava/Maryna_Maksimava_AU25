with base_sales as (
    select
        co.country_region,
        t.calendar_year,
        ch.channel_desc,
        sum(s.amount_sold) as channel_amount
    from sh.sales s
    join sh.times t
      on s.time_id = t.time_id
    join sh.channels ch
      on s.channel_id = ch.channel_id
    join sh.customers c
      on s.cust_id = c.cust_id
    join sh.countries co
      on c.country_id = co.country_id
    where t.calendar_year between 1998 and 2001     -- include 1998 for previous-year calc
      and lower(co.country_region) in ('americas', 'asia', 'europe')
    group by
        co.country_region,
        t.calendar_year,
        ch.channel_desc
),
year_totals as (
    select
        country_region,
        calendar_year,
        sum(channel_amount) as region_year_total
    from base_sales
    group by
        country_region,
        calendar_year
),
with_pct as (
    select
        b.country_region,
        b.calendar_year,
        b.channel_desc,
        b.channel_amount,
        y.region_year_total,
        100.0 * b.channel_amount / y.region_year_total as pct_by_channel
    from base_sales b
    join year_totals y
      on b.country_region = y.country_region
     and b.calendar_year  = y.calendar_year
),
with_prev as (
    select
        country_region,
        calendar_year,
        channel_desc,
        channel_amount,
        region_year_total,
        pct_by_channel,
        lag(pct_by_channel) over (
            partition by country_region, channel_desc
            order by calendar_year
        ) as pct_prev
    from with_pct
)
select
    country_region,
    calendar_year,
    channel_desc,
    to_char(channel_amount, 'fm999,999,999,999,990.00') as "amount_sold",
    round(pct_by_channel, 2)                            as "% by channels",
    round(pct_prev, 2)                                  as "% previous period",
    round(pct_by_channel - pct_prev, 2)                 as "% diff"
from with_prev
where calendar_year between 1999 and 2001               -- show only 1999–2001
order by
    country_region,
    calendar_year,
    channel_desc;



------------------------
with daily_sales as (
    -- 1) aggregate to daily sales and pull weeks 48–52 so edges work
    select
        t.time_id,
        t.calendar_year,
        t.calendar_week_number,
        t.day_name,
        sum(s.amount_sold) as amount_sold
    from sh.sales s
    join sh.times t
      on s.time_id = t.time_id
    where t.calendar_year = 1999
      and t.calendar_week_number between 48 and 52
    group by
        t.time_id,
        t.calendar_year,
        t.calendar_week_number,
        t.day_name
),
calc as (
    select
        d.*,

        -- weekly cumulative sum (running total within each week)
        sum(amount_sold) over (
            partition by calendar_year, calendar_week_number
            order by time_id
            rows between unbounded preceding and current row
        ) as cum_sum,

        -- centered 3-day average via window frame
        avg(amount_sold) over (
            order by time_id
            rows between 1 preceding and 1 following
        ) as centered_3_day_avg,

        -- lags/leads only needed for the special Monday/Friday rule
        lag(amount_sold, 1)  over (order by time_id) as amt_lag1,
        lag(amount_sold, 2)  over (order by time_id) as amt_lag2,
        lead(amount_sold, 1) over (order by time_id) as amt_lead1,
        lead(amount_sold, 2) over (order by time_id) as amt_lead2
    from daily_sales d
)
select
    time_id,
    calendar_week_number,
    day_name,
    round(amount_sold, 2) as amount_sold,
    round(cum_sum, 2)     as "cum_sum",
    round(
        case
            -- monday: sat + sun + mon + tue (lag2, lag1, self, lead1)
            when lower(day_name) = 'monday' then
                (
                    coalesce(amt_lag2, 0) +
                    coalesce(amt_lag1, 0) +
                    amount_sold +
                    coalesce(amt_lead1, 0)
                )
                / nullif(
                    (case when amt_lag2  is not null then 1 else 0 end +
                     case when amt_lag1  is not null then 1 else 0 end +
                     1 +
                     case when amt_lead1 is not null then 1 else 0 end)::numeric,
                    0
                )

            -- friday: thu + fri + sat + sun (lag1, self, lead1, lead2)
            when lower(day_name) = 'friday' then
                (
                    coalesce(amt_lag1, 0) +
                    amount_sold +
                    coalesce(amt_lead1, 0) +
                    coalesce(amt_lead2, 0)
                )
                / nullif(
                    (case when amt_lag1  is not null then 1 else 0 end +
                     1 +
                     case when amt_lead1 is not null then 1 else 0 end +
                     case when amt_lead2 is not null then 1 else 0 end)::numeric,
                    0
                )

            -- other days: centered 3-day avg from the window frame
            else centered_3_day_avg
        end,
        2
    ) as "centered_3_day_avg"
from calc
where calendar_week_number between 49 and 51
order by time_id;


------------------------------------


-- rows
select
    t.time_id,
    t.calendar_year,
    t.calendar_week_number,
    sum(s.amount_sold) as day_amount,
    sum(sum(s.amount_sold)) over (
        partition by t.calendar_year, t.calendar_week_number
        order by t.time_id
        rows between unbounded preceding and current row
    ) as cum_sum_in_week
from sh.sales s
join sh.times t on s.time_id = t.time_id
where t.calendar_year = 1999
  and t.calendar_week_number between 49 and 51
group by t.time_id, t.calendar_year, t.calendar_week_number
order by t.time_id;
-- we want a running total by day, in order of rows within each week, therefore rows


----
-- group
with yearly_sales as (
    select
        co.country_region,
        t.calendar_year,
        sum(s.amount_sold) as year_amount
    from sh.sales s
    join sh.times t      on s.time_id = t.time_id
    join sh.customers c  on s.cust_id = c.cust_id
    join sh.countries co on c.country_id = co.country_id
    where lower(co.country_region) in ('americas', 'asia', 'europe')
      and t.calendar_year between 1998 and 2001
    group by co.country_region, t.calendar_year
)
select
    country_region,
    calendar_year,
    year_amount,
    avg(year_amount) over (
        partition by country_region
        order by calendar_year
        groups between 1 preceding and current row
    ) as avg_last_2_years
from yearly_sales
order by country_region, calendar_year;
-- calculations are conducted on year level
-- if there were duplicate rows per year in the partition,
-- groups treats all rows with the same calendar_year value
-- as one group, not separate row positions. 


---
-- range
select
    t.time_id,
    sum(s.amount_sold) as day_amount,
    sum(sum(s.amount_sold)) over (
        order by t.time_id
        range between interval '6 days' preceding and current row
    ) as rolling_7_day_sales
from sh.sales s
join sh.times t on s.time_id = t.time_id
where t.calendar_year = 2000
group by t.time_id
order by t.time_id;
-- if there are multiple rows for the same date,
-- range includes all of them, because it uses the value in order by,
-- not row position.
