select s.sbs_no as "SBS NO",
	st.store_no as "STORE NO", 
	st.store_name as "STORE NAME",
	do.order_doc_no as "ORDER NO", 
	(nvl(do.bt_first_name,'')||' '|| nvl(do.bt_last_name,'')) as "CUSTOMER NAME",
	do.bt_primary_phone_no as "PHONE NO",
	trunc(do.created_datetime) as "ORDER DATE",
	trunc(do.modified_datetime) as "LAST ACTIVITY",
	trunc((select max(td.created_datetime)
				from rps.document d1 
				inner join rps.tender td on td.doc_sid = d1.sid
				where (d1.sid = do.sid or d1.ref_order_sid = do.sid))) as "LAST DEPOSIT",
	(case when do.so_cancel_flag = 1 then 'CLOSED' 
		 else (case do.order_status 
					when 2 then 'COMPLETE' 
					When 1 then 'PARTIAL'
				else 'PENDING' end) 
	end) as "STATUS",
	nvl(do.order_qty,0) AS "ORDER QTY",
	nvl(do.ORDER_QUANTITY_FILLED ,0) AS "QTY FULFILLED",
	nvl(do.order_total_amt,0) as "TOTAL ORDER AMOUNT",
	nvl(do.TOTAL_DEPOSIT_TAKEN,0) as "TOTAL DEPOSIT",
	nvl(do.total_deposit_used,0) as "DEPOSIT USED",
	nvl(used_subtotal,0) + nvl(used_tax,0) + nvl(used_fee_amt1,0) 
		+ nvl(used_fee_amt1, 0) + nvl(used_shipping_amt,0) as "TOTAL FULFILLED AMOUNT",
	(case when do.so_cancel_flag = 1 
		 then 0.00 
		 else nvl(do.order_total_amt,0) 
			-  (nvl(used_subtotal,0) + nvl(used_tax,0) + nvl(used_fee_amt1,0) 
				+ nvl(used_fee_amt1, 0) + nvl(used_shipping_amt,0)) 
		end) as "BALANCE"
from rps.document do
inner join rps.subsidiary s
on do.sbs_no = s.sbs_no
inner join rps.store st
on st.sid = do.store_sid
and s.sid = do.subsidiary_sid
where (do.receipt_type = 2 or do.so_cancel_flag = 1)
and do.order_type in (2)
and do.status = 4 
--and trunc(do.created_datetime)='19-FEB-2024'
and =-=s.sbs_no=-=
and =-=st.store_no=-=
and =-=st.store_code=-=
and =-=cast(do.created_datetime as date)=-= 
order by do.sbs_no, do.store_no, do.order_doc_no