	   select r.sbs_name as "SBS_NAME",
r.store_code as "STORE_CODE",
       r.dcs_code as "DCS_CODE",
       r.vend_code as "VENDOR CODE",
       r.description1 as "DESCRIPTION1",
       r.attribute as "ATTRIBUTE",
       r.item_size as "SIZE",
       r.upc as "UPC",
	   r.alu as "ALU",
       r.qty_sold as "SOLD QTY",
       r.ext_cost as "EXT COST",
	   r.ext_orig_price as "EXT ORIG PRICE",
	   r.ext_orig_priceWT as "EXT ORIG PRICE W TAX",
	   r.ext_disc as "EXT DISC",
round(case when r.ext_orig_price = 0 then 0 else (r.ext_disc/ (CASE WHEN R.USE_VAT=1 THEN r.ext_orig_priceWT ELSE r.ext_orig_price END)*100) end, 2) as "DISC%",
       r.ext_price as "EXT PRICE",
	   r.ext_priceWT as "EXT PRICE W TAX",
r.ext_tax as "EXT TAX",
       (r.ext_price - r.ext_cost) as "EXT MARGIN",
       round(
            case when r.ext_price = 0
                then 0
                else (r.ext_price - r.ext_cost) /r.ext_price*100
            end, 2) as "MARGIN%"
from
(
    select s.sbs_name,
          do.store_code,
           d.dcs_code,
           v.vend_code,
           i.description1,
           i.attribute,
           i.item_size,
           i.upc,
		   i.alu, do.use_vat,
           sum(decode(di.item_type, 2, di.qty * -1, di.qty)) as qty_sold,
           sum(round((decode(di.item_type, 2, di.qty * -1, di.qty) * (di.cost)), 2)) as ext_cost,
		   sum(round((decode(di.item_type, 2, di.qty * -1, di.qty) * decode(do.use_vat,1,di.orig_price-di.orig_tax_amt, di.orig_price)), 2)) as ext_orig_price,
		   sum(round((decode(di.item_type, 2, di.qty * -1, di.qty) * decode(do.use_vat,1,di.orig_price, di.orig_price+di.orig_tax_amt)), 2)) as ext_orig_priceWT,
		   sum(round((decode(di.item_type, 2, di.qty * -1, di.qty) * decode(do.use_vat,1,di.price-di.tax_amt-di.tax2_amt, di.price)), 2)) as ext_price,
           sum(round((decode(di.item_type, 2, di.qty * -1, di.qty) * decode(do.use_vat,1,di.price, di.price+di.tax_amt+di.tax2_amt)), 2)) as ext_pricewt,
		SUM(ROUND((CASE WHEN di.ITEM_TYPE=2 THEN di.QTY*-1 ELSE di.QTY END) * (di.DISC_AMT),2)) ext_disc, 
          round(sum(decode(di.item_type,2,di.qty*-1,di.qty)*(di.tax_amt+di.tax2_amt)),2) ext_tax
      from rps.document do
     inner join rps.document_item di
        on do.sid = di.doc_sid
     inner join rps.subsidiary s
        on do.sbs_no = s.sbs_no
       and di.sbs_no = s.sbs_no
     inner join rps.dcs d
        on s.sid = d.sbs_sid
       and di.dcs_code = d.dcs_code
     inner join rps.store st
        on do.store_sid = st.sid
     inner join rps.invn_sbs_item i
        on di.invn_sbs_item_sid = i.sid
       and s.sid = i.sbs_sid
     left join rps.vendor v
        on i.vend_sid = v.sid
     where do.receipt_type in (0, 1)
       and di.item_type in (1, 2)
       and do.status = 4
       and =-=do.sbs_no=-=
       and =-=st.store_no=-=
       and =-=st.store_code=-=
       and =-=trunc(do.created_datetime)=-=
    group by s.sbs_name, do.store_code, 
           d.dcs_code,
           v.vend_code,
           i.description1,
           i.attribute,
           i.item_size,
           i.upc, i.alu, do.use_vat
) r     
ORDER BY 
  r.sbs_name,
  r.dcs_code,
  r.vend_code,
  r.description1, r.attribute, r.item_size, r.upc, r.alu