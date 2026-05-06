SELECT s.sbs_name
          AS "SBS NAME",
       a.store_code
          AS "STORE CODE",
       a.order_doc_no
          AS "SO NO",
       a.bt_first_name || ' ' || a.bt_last_name
          AS "BILL TO NAME",
       TRUNC (a.invc_post_date)
          AS "ORDER DATE",   
       TRUNC (a.ship_date)
          AS "SHIPPING DATE",   
       TRUNC (a.cancel_date)
          AS "CANCELLED DATE",
       ROUND(a.order_subtotal, 2) 
          AS "ORDER PRICE",
       ROUND(a.so_deposit_amt_paid, 2) 
          AS "DEPOSIT BALANCE",
       ROUND(a.order_total_amt - a.so_deposit_amt_paid, 2) 
          AS "BALANCE DUE"         
  FROM rps.document  a
       JOIN rps.subsidiary s ON a.subsidiary_sid = s.sid 
       JOIN rps.store st ON st.sid = a.store_sid
 WHERE a.receipt_type IN (2) 
   AND a.status = 4
   AND a.is_held = 0
  and =-=a.sbs_no=-= and =-=a.store_no=-= and =-=trunc(a.invc_post_date)=-=
