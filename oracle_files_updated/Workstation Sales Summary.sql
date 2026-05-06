select doc.sbs_no, doc.store_code, doc.store_name ,
       doc.workstation_no , doc.workstation_name,
       doc.transac AS "TRANSACTION COUNT",
       doc.sold_qty AS "SOLD QTY",
       doc.return_qty AS "RETURN QTY",
       round(doc.net_qty / doc.transac, 2) AS "AVG UNITS",
       doc.gross_sales AS "GROSS SALES W TAX",
       doc.gross_return AS "GROSS RETURNS W TAX",
       doc.net_sales AS "NET SALES W TAX",
       round(doc.net_sales / doc.transac, 2) AS "AVG SALES",
       round((doc.transac  / transac_total
               ) * 100, 2) AS "TRANSACTION PERCENT",
       round(
         CASE WHEN doc.gross_sales_total != 0
              THEN ((doc.gross_sales / gross_sales_total) * 100)  
              ELSE 0 END, 2) AS "SALES PERCENT"
from
(
   select do.*,
          sum(do.transac)
            OVER (PARTITION BY do.sbs_no, do.store_code) as transac_total,
          sum(do.gross_sales)
            OVER (PARTITION BY do.sbs_no, do.store_code) as gross_sales_total
   from
      (
      select d.sbs_no, d.store_code, d.store_name,
             d.workstation_no, d.workstation_name,
             COUNT(d.sid) as transac,
             sum(d.sold_qty + (d.return_qty * -1)) as net_qty,
             sum(d.sold_qty) as sold_qty,
             sum(d.return_qty * -1) as return_qty,
			 round(sum((case when di.item_type = 2 then 0 else di.qty end) * decode(d.use_vat,1,di.orig_price,di.orig_price+di.orig_tax_amt)),2) as gross_sales,
		    round(sum((case when di.item_type = 2 then di.qty*-1 else 0 end) * decode(d.use_vat,1,di.orig_price,di.orig_price+di.orig_tax_amt)),2) as gross_return,
           round(sum((case when di.item_type = 2 then di.qty*-1 else di.qty end) * decode(d.use_vat,1,di.price, di.price+di.tax_amt+di.tax2_amt)),2) as net_sales
        from rps.document d, rps.document_item di
       where d.receipt_type in (0,1)
         and d.status = 4 and d.sid=di.doc_sid
         and =-=trunc(d.invc_post_date)=-=
      group by d.sbs_no, d.store_code, d.store_name,
               d.workstation_no, d.workstation_name
      ) do
   )doc
order by  doc.sbs_no, doc.store_code, doc.store_name, doc.workstation_no, doc.workstation_name


