select * from (
select s.sbs_no,d.dcs_code,i.description1,
sum(decode(b.item_type,2,b.qty*-1,b.qty)) "SOLD QTY",
round(sum(decode(b.item_type,2,b.qty*-1,b.qty)*decode(a.use_vat,1,b.price-b.tax_amt-b.tax2_amt, b.price)),2) "EXT PRICE",
round(sum(decode(b.item_type,2,b.qty*-1,b.qty)*decode(a.use_vat,1,b.price, b.price+b.tax_amt+b.tax2_amt)),2) "EXT PRICE W TAX",
dense_rank() over(order by sum(decode(b.item_type,2,b.qty*-1,b.qty)*decode(a.use_vat,1,b.price, b.price+b.tax_amt+b.tax2_amt)) desc) Ranks
from rps.document a inner join 
rps.document_item b on a.sid=b.doc_sid
inner join rps.subsidiary s on a.sbs_no=s.sbs_no and b.sbs_no=s.sbs_no 
inner join rps.dcs d on s.sid=d.sbs_sid and b.dcs_code=d.dcs_code
inner join rps.invn_sbs_item i on b.invn_sbs_item_sid=i.sid and s.sid=i.sbs_sid
where  1=1  and =-=s.sbs_no=-= and  a.receipt_type in (0,1) and b.item_type in (1,2) and a.status=4 and =-=trunc(a.invc_post_date)=-=
group by s.sbs_no, d.dcs_code,i.description1
) aa
where 1=1  and =-=ranks=-=
