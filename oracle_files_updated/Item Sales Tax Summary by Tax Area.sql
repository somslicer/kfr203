select a.sbs_no, a.store_no,a.store_code,trunc(a.invc_post_date) RECEIPT_DATE,a.tax_area_name tax_area,a.tax_area2_name tax_area2, 
b.tax_code,b.tax_perc, b.tax2_perc "TAX_PERC2",i.alu,to_char(i.upc) UPC,i.description1,i.description2,i.attribute,i.item_size,
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
round(sum(decode(b.item_type,2,b.qty*-1,b.qty)*(b.tax_amt+b.tax2_amt)),2) "EXT TAX"
from rps.document a inner join 
rps.document_item b on a.sid=b.doc_sid
inner join rps.subsidiary s on a.sbs_no=s.sbs_no and b.sbs_no=s.sbs_no
inner join rps.dcs d on s.sid=d.sbs_sid and b.dcs_code=d.dcs_code
inner join rps.invn_sbs_item i on b.invn_sbs_item_sid=i.sid and s.sid=i.sbs_sid
left join rps.invn_sbs_extend it on i.sid=it.invn_sbs_item_sid
where  1=1 and  a.receipt_type in (0,1) and b.item_type in (1,2) and  a.status=4
and =-=a.sbs_no=-= and =-=a.store_no=-= and =-=trunc(a.invc_post_date)=-=
group by a.sbs_no, a.store_no,a.store_code,trunc(a.invc_post_date),a.tax_area_name,a.tax_area2_name, b.tax_code,b.tax_perc, b.tax2_perc,
i.alu,i.upc,i.description1,i.description2,i.attribute,i.item_size
order by a.sbs_no, a.store_no,a.store_code,trunc(a.invc_post_date),a.tax_area_name,a.tax_area2_name, b.tax_code,b.tax_perc, b.tax2_perc,
i.alu,i.upc,i.description1,i.description2,i.attribute,i.item_size