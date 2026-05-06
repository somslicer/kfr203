SELECT Sal.sbs_no, Sal.sbs_name, Sal.vend_code, Sal.LSQ "LAST SOLD QTY", Sal.LC "LAST EXT COST", Sal.LPT "LAST EXT PRICE W TAX", (Sal.LPT-Sal.LC) "LAST EXT MARGIN", 
       round(case when Sal.LPT = 0 then 0 else (Sal.LPT - Sal.LC) /Sal.LPT * 100 end, 2) as "LAST MARGIN%",
Sal.CSQ "CURRENT SOLD QTY", Sal.CC "CURRENT EXT COST", Sal.CPT "CURRENT EXT PRICE W TAX", (Sal.CPT-Sal.CC) "CURRENT EXT MARGIN", 
       round(case when Sal.CPT = 0 then 0 else (Sal.CPT - Sal.CC) /Sal.CPT * 100 end, 2) as "CURRENT MARGIN%"
from	   
(select s.sbs_no, s.sbs_name, b.vend_code, 
sum(case when =-=cast(a.Invc_Post_Date as date)=-= then decode(b.item_type,2,b.qty*-1,b.qty) else 0 end) LSQ,
round(sum(case when =-=cast(a.Invc_Post_Date as date)=-= then decode(b.item_type,2,b.qty*-1,b.qty)*decode(a.use_vat,1,b.price-b.tax_amt-b.tax2_amt, b.price) else 0 end),2) LP,
round(sum(case when =-=cast(a.Invc_Post_Date as date)=-= then decode(b.item_type,2,b.qty*-1,b.qty)*decode(a.use_vat,1,b.price, b.price+b.tax_amt+b.tax2_amt) else 0 end),2) LPT,
round(sum(case when =-=cast(a.Invc_Post_Date as date)=-= then decode(b.item_type,2,b.qty*-1,b.qty)* (b.cost) else 0 end),2) LC,
sum(case when =-=cast(a.invc_post_date as date)=-= then decode(b.item_type,2,b.qty*-1,b.qty) else 0 end) CSQ,
round(sum(case when =-=cast(a.invc_post_date as date)=-= then decode(b.item_type,2,b.qty*-1,b.qty)*decode(a.use_vat,1,b.price-b.tax_amt-b.tax2_amt, b.price) else 0 end),2) CP,
round(sum(case when =-=cast(a.invc_post_date as date)=-= then decode(b.item_type,2,b.qty*-1,b.qty)*decode(a.use_vat,1,b.price, b.price+b.tax_amt+b.tax2_amt) else 0 end),2) CPT,
round(sum(case when =-=cast(a.invc_post_date as date)=-= then decode(b.item_type,2,b.qty*-1,b.qty) * (b.cost) else 0 end),2) CC
from rps.document a inner join 
rps.document_item b on a.sid=b.doc_sid
inner join rps.subsidiary s on a.sbs_no=s.sbs_no and b.sbs_no=s.sbs_no 
inner join rps.dcs d on s.sid=d.sbs_sid and b.dcs_code=d.dcs_code
inner join rps.invn_sbs_item i on b.invn_sbs_item_sid=i.sid and s.sid=i.sbs_sid
left join rps.invn_sbs_extend it on i.sid=it.invn_sbs_item_sid
where  1=1 and =-=s.sbs_no=-= and 
a.receipt_type in (0,1) and b.item_type in (1,2) and  a.status=4 and
(=-=cast(a.Invc_Post_Date as date)=-=
or =-=cast(a.invc_post_date as date)=-=
)
group by s.sbs_no, s.sbs_name, b.vend_code
order by s.sbs_no, s.sbs_name, b.vend_code)
Sal