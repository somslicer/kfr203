
select do.sbs_no AS "SBS_NO",
       st.store_code "STORE_CODE",
       e.full_name AS "ASSOCIATE",  
       trunc(do.invc_post_date) as "DATE",
       to_char(do.invc_post_date, 'hh:mi:ss am') as "TIME",
       do.doc_no AS "TRANSACTION NO",
       do.workstation_no AS "WORKSTATION NO",
       do.workstation_name AS "WORKSTATION",
	   sum((case when di.item_type = 2 then di.qty*-1 else di.qty end)) as "SOLD QTY",
       round(sum((decode(di.item_type, 2, di.qty * -1, di.qty)
               * decode(do.use_vat,1,di.orig_price-di.orig_tax_amt, di.orig_price))), 2) as "ORIGINAL PRICE",
       round(sum((decode(di.item_type, 2, di.qty * -1, di.qty)
               * decode(do.use_vat,1,di.orig_price, di.orig_price+di.orig_tax_amt))), 2) as "ORIGINAL PRICE W TAX",
       round(sum((decode(di.item_type, 2, di.qty * -1, di.qty)
               * decode(do.use_vat,1,di.price-di.tax_amt-di.tax2_amt, di.price))), 2) as "DISCOUNTED PRICE",
       round(sum((decode(di.item_type, 2, di.qty * -1, di.qty)
               * decode(do.use_vat,1,di.price, di.price+di.tax_amt+di.tax2_amt))), 2) as "DISCOUNTED PRICE W TAX",
       di.discount_reason AS "REASON"      
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
left join rps.employee e
    on e.sid = di.employee1_sid
 where do.receipt_type in (0, 1)
   and di.item_type in (1, 2)
   and do.status = 4
   and di.disc_amt <> 0 and =-=s.sbs_no=-= and =-=a.store_no=-= and =-=trunc(do.invc_post_date)=-=
   group by do.sbs_no, st.store_code, e.full_name, trunc(do.invc_post_date), 
   to_char(do.invc_post_date, 'hh:mi:ss am'), do.doc_no, do.workstation_no, do.workstation_name, di.discount_reason
   order by do.sbs_no, st.store_code, e.full_name, trunc(do.invc_post_date), 
   to_char(do.invc_post_date, 'hh:mi:ss am'), do.doc_no, do.workstation_no, do.workstation_name, di.discount_reason
