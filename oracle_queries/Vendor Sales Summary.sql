select r.sbs_name as "SBS NAME",
       r.vend_code as "VENDOR CODE",
       r.QtySold as "SOLD QTY",
	   r.EXTOP as "EXT ORIG PRICE",
       r.EXTOPW as "EXT ORIG PRICE W TAX",
       round(case when r.EXTOP = 0 then 0 else (r.EXTD/decode(r.use_vat,1,r.EXTOPW,r.EXTOP)*100) end, 2) as "DISC%",
       r.EXTD as "EXT DISC AMT",
	   r.EXTP as "EXT PRICE",
       r.EXTPW as "EXT PRICE W TAX",
       r.EXTC as "EXT COST",
       (r.EXTP - r.EXTC) as "EXT MARGIN AMT",
       round((case when r.EXTP = 0 then 0 else (r.EXTP - r.EXTC)/r.EXTP * 100 end),2) as "MARGIN%"
from (
    select s.sbs_name,
           v.vend_code,
a.use_vat, 
           sum((case when b.item_type = 2 then b.qty*-1 else b.qty end)) as QtySold,
           round(sum((case when b.item_type = 2 then b.qty*-1 else b.qty end) * decode(a.use_vat,1,b.orig_price-b.orig_tax_amt, b.orig_price)),2) as EXTOP,
		   round(sum((case when b.item_type = 2 then b.qty*-1 else b.qty end) * decode(a.use_vat,1,b.orig_price, b.orig_price+b.orig_tax_amt)),2) as EXTOPW,
		   round(sum((case when b.item_type = 2 then b.qty*-1 else b.qty end) * decode(a.use_vat,1,b.price-b.tax_amt-b.tax2_amt, b.price)),2) as EXTP,
           round(sum((case when b.item_type = 2 then b.qty*-1 else b.qty end) * decode(a.use_vat,1,b.price, b.price+b.tax_amt+b.tax2_amt)),2) as EXTPW,
           round(sum((case when b.item_type = 2 then b.qty*-1 else b.qty end) * (b.disc_amt)), 2) as EXTD,
           round(sum((case when b.item_type = 2 then b.qty*-1 else b.qty end) * (b.cost)), 2) as "EXTC"
      from rps.document a
     inner join rps.document_item b on a.sid=b.doc_sid
     inner join rps.subsidiary s on a.sbs_no=s.sbs_no and b.sbs_no=s.sbs_no
     inner join rps.dcs d on s.sid=d.sbs_sid and b.dcs_code=d.dcs_code
     inner join rps.invn_sbs_item i on b.invn_sbs_item_sid=i.sid and s.sid=i.sbs_sid
     left join rps.vendor v on i.vend_sid = v.sid
     where 1=1 and a.receipt_type in (0,1) and b.item_type in (1,2) and a.status=4
       and =-=s.sbs_no=-=
       and =-=a.store_no=-=
       and =-=a.store_code=-=
       and =-=trunc(a.created_datetime)=-=
    group by s.sbs_name,v.vend_code, a.use_vat
) r
order by r.sbs_name,r.vend_code