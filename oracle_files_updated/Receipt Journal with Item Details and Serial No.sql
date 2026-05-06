
SELECT s.sbs_name
          AS "SBS_NAME",
       a.store_code
          AS "STORE CODE",
       a.doc_no
          AS "RECEIPT NO",
       TRUNC (a.invc_post_date)
          AS "RCPT DATE",
       TO_CHAR (a.invc_post_date, 'hh:mi:ss am')
          AS "RCPT TIME",
       a.tender_name
          AS "TENDER NAME",
       i.upc as "UPC",
       i.alu AS "ALU",
       b.dcs_code as "DCS CODE",
       b.vend_code as "VENDOR",
       b.attribute as "ATTR",
       b.item_size as "SIZE", 
       b.description1 as "DESCRIPTION 1",  
b.serial_no,
sum(decode(b.item_type,2,b.qty*-1,b.qty)) "SOLD QTY", b.cost, 
round(sum((case when b.item_type = 2 then b.qty*-1 else b.qty end) * (b.cost)), 2) as "EXT COST",
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
  FROM rps.document  a
       JOIN rps.document_item b ON a.sid = b.doc_sid
       JOIN rps.subsidiary s ON a.sbs_no = s.sbs_no AND b.sbs_no = s.sbs_no
       JOIN rps.store st ON st.sid = a.store_sid
       JOIN rps.invn_sbs_item i ON i.sid = b.invn_sbs_item_sid
 WHERE a.receipt_type IN (0, 1) AND b.item_type IN (1, 2) AND a.status = 4
 and =-=a.sbs_no=-= and =-=a.store_no=-= and =-=trunc(a.invc_post_date)=-=
 Group By S.Sbs_Name, A.Store_Code, A.Doc_No, Trunc (A.invc_post_date), To_Char (A.invc_post_date, 'hh:mi:ss am'),
       a.tender_name, i.upc, i.alu, b.dcs_code, b.vend_code, b.attribute, B.Item_Size, B.Description1, b.serial_no, b.cost
order By S.Sbs_Name, A.Store_Code, A.Doc_No, Trunc(A.invc_post_date), To_Char(A.invc_post_date, 'hh:mi:ss am'),
       a.tender_name, i.upc, i.alu, b.dcs_code, b.vend_code, b.attribute, B.Item_Size, B.Description1, b.serial_no 