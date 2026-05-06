select a.sbs_no, a.store_code,extract(year from a.created_datetime) YEAR,extract(month from a.created_datetime) "MONTH",d.dcs_code DCS_CODE,to_char(i.upc) upc,i.description1,
sum(decode(b.item_type,2,b.qty*-1,b.qty)) "SOLD QTY",sum(decode(b.item_type,2,b.qty*-1,0)) "RETURN QTY",
round(sum((case when b.item_type = 2 then b.qty*-1 else b.qty end) * (b.cost)), 2) as "EXT COST",
round(sum(decode(b.item_type,2,b.qty*-1,b.qty)* decode(a.use_vat,1,b.orig_price-b.orig_tax_amt, b.orig_price)),2) "EXT ORIG PRICE",
round(sum(decode(b.item_type,2,b.qty*-1,b.qty)*decode(a.use_vat,1,b.orig_price, b.orig_price+b.orig_tax_amt)),2) "EXT ORIG PRICE W TAX",
ROUND(avg(b.DISC_PERC),2) DISC_PERC, 
round((sum(decode(b.item_type,2,b.qty*-1,b.qty)* decode(a.use_vat,1,b.orig_price-b.orig_tax_amt, b.orig_price))-sum(decode(b.item_type,2,b.qty*-1,b.qty)* decode(a.use_vat,1,b.price-b.tax_amt-b.tax2_amt, b.price))),2) "EXT DISC",
round((sum(decode(b.item_type,2,b.qty*-1,b.qty)* decode(a.use_vat,1,b.orig_price, b.orig_price+b.orig_tax_amt))-sum(decode(b.item_type,2,b.qty*-1,b.qty)* decode(a.use_vat,1,b.price, b.price+b.tax_amt+b.tax2_amt))),2) "EXT DISC W TAX",
round(sum(decode(b.item_type,2,b.qty*-1,b.qty)* decode(a.use_vat,1,b.price-b.tax_amt-b.tax2_amt, b.price)),2) "EXT PRICE",
round(sum(decode(b.item_type,2,b.qty*-1,b.qty)*decode(a.use_vat,1,b.price, b.price+b.tax_amt+b.tax2_amt)),2) "EXT PRICE W TAX"
from rps.document a inner join 
rps.document_item b on a.sid=b.doc_sid
inner join rps.subsidiary s on a.sbs_no=s.sbs_no and b.sbs_no=s.sbs_no 
inner join rps.dcs d on s.sid=d.sbs_sid and b.dcs_code=d.dcs_code
inner join rps.invn_sbs_item i on b.invn_sbs_item_sid=i.sid and s.sid=i.sbs_sid
left join rps.invn_sbs_extend it on i.sid=it.invn_sbs_item_sid
where 1=1 and  a.receipt_type in (0,1) and b.item_type in (1,2) and  a.status=4 
and =-=s.sbs_no=-= and =-=a.store_no=-= and =-=trunc(a.created_datetime)=-=
group by a.sbs_no,a.store_no,a.store_code,extract(year from a.created_datetime) ,extract(month from a.created_datetime),d.dcs_code,i.upc,i.description1
order by a.sbs_no,a.store_no,a.store_code,extract(year from a.created_datetime) ,extract(month from a.created_datetime),d.dcs_code,i.upc,i.description1