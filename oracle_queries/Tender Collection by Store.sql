select s.sbs_no, a.store_no,a.store_code,trunc(a.created_datetime) Sales_date,itd.tender_name,itd.currency_name,
round(sum(itd.amount),2) Amount
from rps.document a
left join rps.tender itd
on a.sid=itd.doc_sid
left join rps.subsidiary s
on a.sbs_no=s.sbs_no 
where 1=1 and =-=s.sbs_no=-= and  a.receipt_type in (0,1) and  a.status=4 and =-=trunc(a.created_datetime)=-=
group by s.sbs_no, a.store_no,a.store_code,trunc(a.created_datetime),itd.tender_name,itd.currency_name