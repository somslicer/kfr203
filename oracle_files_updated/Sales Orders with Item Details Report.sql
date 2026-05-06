select s.sbs_no as "SBS NO",
	st.store_no as "STORE NO",
	st.store_code as "STORE CODE",
	trunc(d.invc_post_date) AS "CREATED DATE",
	(nvl(d.bt_first_name,'')||' '|| nvl(d.bt_last_name,'')) as "CUSTOMER NAME",
	d.order_doc_no AS "ORDER NO",
	i.alu as "ALU",
	i.Description1 as "DESCRIPTION1",
	i.Description2 as "DESCRIPTION2",
	i.attribute as "ATTRIBUTE",
	i.item_size as "ITEM_SIZE",
	d.cashier_full_name as "CASHIER NAME",
	d.reason_description as "REASON",
	di.qty as "ORDER QTY",
	nvl(di.Order_Quantity_Filled,0) as "QTY FULFILLED",
 ROUND (
          (  (CASE WHEN di.item_type = 2 THEN di.qty * -1 ELSE di.qty END)
           * decode(d.use_vat,1,di.price-di.tax_amt-di.tax2_amt, di.price)),
          2)
          AS "ORDER PRICE",
       ROUND (
          (  (CASE WHEN di.item_type = 2 THEN di.qty * -1 ELSE di.qty END)
           * (decode(d.use_vat,1,di.price, di.price+di.tax_amt+di.tax2_amt))),
          2)
          AS "ORDER PRICE W TAX"
from rps.document d
inner join rps.document_item di on di.doc_sid = d.sid
inner join rps.subsidiary s on s.sid = d.subsidiary_sid
inner join rps.store st on st.sid = d.store_sid
inner join rps.invn_sbs_item i on i.sid = di.invn_sbs_item_sid
where d.order_type = 0
and di.item_type = 3
and d.status = 4
and =-=s.sbs_no=-=
and =-=st.store_no=-=
and =-=st.store_code=-=
and =-=cast(d.invc_post_date as date)=-= 
order by d.invc_post_date desc