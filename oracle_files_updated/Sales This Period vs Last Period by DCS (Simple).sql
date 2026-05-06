select s.sbs_no, d.dcs_code,
sum(case when =-=cast(a.Invc_Post_Date as date)=-= then decode(b.item_type,2,b.qty*-1,b.qty) else 0 end) "LAST SOLD QTY",
round(sum(case when =-=cast(a.Invc_Post_Date as date)=-= then decode(b.item_type,2,b.qty*-1,b.qty)*decode(a.use_vat,1,b.price-b.tax_amt-b.tax2_amt, b.price) else 0 end),2) "LAST EXT PRICE",
round(sum(case when =-=cast(a.Invc_Post_Date as date)=-= then decode(b.item_type,2,b.qty*-1,b.qty)*decode(a.use_vat,1,b.price, b.price+b.tax_amt+b.tax2_amt) else 0 end),2) "LAST EXT PRICE W TAX",
sum(case when =-=cast(a.invc_post_date as date)=-= then decode(b.item_type,2,b.qty*-1,b.qty) else 0 end) "CURRENT SOLD QTY",
round(sum(case when =-=cast(a.invc_post_date as date)=-= then decode(b.item_type,2,b.qty*-1,b.qty)*decode(a.use_vat,1,b.price-b.tax_amt-b.tax2_amt, b.price) else 0 end),2) "CURRENT EXT PRICE",
round(sum(case when =-=cast(a.invc_post_date as date)=-= then decode(b.item_type,2,b.qty*-1,b.qty)*decode(a.use_vat,1,b.price, b.price+b.tax_amt+b.tax2_amt) else 0 end),2) "CURRENT EXT PRICE W TAX"
from rps.document a inner join 
rps.document_item b on a.sid=b.doc_sid
inner join rps.subsidiary s on a.sbs_no=s.sbs_no and b.sbs_no=s.sbs_no 
inner join rps.dcs d on s.sid=d.sbs_sid and b.dcs_code=d.dcs_code
inner join rps.invn_sbs_item i on b.invn_sbs_item_sid=i.sid and s.sid=i.sbs_sid
left join rps.invn_sbs_extend it on i.sid=it.invn_sbs_item_sid
where  1=1 and =-=s.sbs_no=-= and  a.receipt_type in (0,1) and b.item_type in (1,2) and   a.status=4 and
(=-=cast(a.Invc_Post_Date as date)=-=
or =-=cast(a.invc_post_date as date)=-=
)
group by s.sbs_no, d.dcs_code
order by s.sbs_no, d.dcs_code