select a.sbs_no, a.store_no,a.store_code,extract(year from trunc(a.created_datetime)) YEAR,extract(month from trunc(a.created_datetime)) MONTH,
sum(decode(b.item_type,2,b.qty*-1,b.qty)) "SOLD QTY",
round(sum(decode(b.item_type,2,b.qty*-1,b.qty)* decode(a.use_vat,1,b.orig_price-b.orig_tax_amt, b.orig_price)),2) "EXT ORIG PRICE",
round(sum(decode(b.item_type,2,b.qty*-1,b.qty)*decode(a.use_vat,1,b.orig_price, b.orig_price+b.orig_tax_amt)),2) "EXT ORIG PRICE W TAX",
decode(sum(decode(b.item_type,2,b.qty*-1,b.qty)* decode(a.use_vat,1,b.orig_price, b.orig_price+b.orig_tax_amt)),0,0,
round((sum(decode(b.item_type,2,b.qty*-1,b.qty)* decode(a.use_vat,1,b.orig_price, b.orig_price+b.Orig_tax_amt))-sum(decode(b.item_type,2,b.qty*-1,b.qty)* decode(a.use_vat,1,b.price, b.price+b.tax_amt+b.tax2_amt)))/
sum(decode(b.item_type,2,b.qty*-1,b.qty)*decode(a.use_vat,1,b.orig_price, b.orig_price+b.orig_tax_amt))*100,2)) DISC_PERC,
round((sum(decode(b.item_type,2,b.qty*-1,b.qty)* decode(a.use_vat,1,b.orig_price-b.orig_tax_amt, b.orig_price))-sum(decode(b.item_type,2,b.qty*-1,b.qty)* decode(a.use_vat,1,b.price-b.tax_amt-b.tax2_amt, b.price))),2) "EXT DISC",
round((sum(decode(b.item_type,2,b.qty*-1,b.qty)* decode(a.use_vat,1,b.orig_price, b.orig_price+b.orig_tax_amt))-sum(decode(b.item_type,2,b.qty*-1,b.qty)* decode(a.use_vat,1,b.price, b.price+b.tax_amt+b.tax2_amt))),2) "EXT DISC W TAX",
round(sum(decode(b.item_type,2,b.qty*-1,b.qty)* decode(a.use_vat,1,b.price-b.tax_amt-b.tax2_amt, b.price)),2) "EXT PRICE",
round(sum(decode(b.item_type,2,b.qty*-1,b.qty)*decode(a.use_vat,1,b.price, b.price+b.tax_amt+b.tax2_amt)),2) "EXT PRICE W TAX",
sum(decode(b.item_type,2,b.qty*-1,0)) "RETURN QTY",
round(sum(decode(b.item_type,2,b.qty*-1,0)* decode(a.use_vat,1,b.price-b.tax_amt-b.tax2_amt, b.price)),2) "EXT RETURN PRICE"
from rps.document a,rps.document_item b,rps.subsidiary s
where a.sid=b.doc_sid and a.sbs_no=s.sbs_no
and b.sbs_no=s.sbs_no
and  a.receipt_type in (0,1) and b.item_type in (1,2) and  a.status=4
and =-=a.sbs_no=-= and =-=a.store_no=-= and =-=trunc(a.created_datetime)=-=
group by a.sbs_no, a.store_no,a.store_code,extract(year from trunc(a.created_datetime)),extract(month from trunc(a.created_datetime))
order by a.sbs_no, a.store_no,a.store_code,extract(year from trunc(a.created_datetime)),extract(month from trunc(a.created_datetime))