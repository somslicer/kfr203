
	select s.sbs_no, st.store_no,st.store_code,d.dcs_code,
	sum(iq.qty) ON_HAND,round(sum(iq.qty*nvl(ip.price,0)),2) On_Hand_ExtPrice,
	sum(nvl(sal.qty,0)) P1_Sold_qty,round(sum(nvl(sal.val,0)),2) P1_Sold_Value,
	sum(nvl(sal2.qty,0)) P2_Sold_qty,round(sum(nvl(sal2.val,0)),2) P2_Sold_Value,sum(iq.asn_in_transit_qty) Intransit_qty
	from rps.invn_sbs_item i 
	inner join rps.subsidiary s
	on i.sbs_sid=s.sid 
	inner join rps.invn_sbs_item_Qty iq
	on i.sbs_sid=iq.sbs_sid and i.sid=iq.invn_sbs_item_sid
	inner join rps.store st
	on iq.sbs_sid=st.sbs_sid and iq.store_sid=st.sid and s.sid=st.sbs_sid
	inner join rps.dcs d
	on i.sbs_sid=d.sbs_sid and i.dcs_sid=d.sid
	left join (select s.sid sbs_sid,invn_sbs_item_sid,ip.price 
	from rps.subsidiary s,rps.invn_sbs_price ip
	where s.sid=ip.sbs_sid and s.active_price_lvl_sid=ip.price_lvl_sid) ip
	on i.sbs_sid=ip.sbs_sid and i.sid=ip.invn_sbs_item_sid
	left join rps.invn_sbs_extend it 
	on i.sid=it.invn_sbs_item_sid
	left join rps.invn_style isy 
	on i.style_sid=isy.sid
	left join (select a.sbs_no,a.store_sid,b.invn_sbs_item_sid,
	sum(decode(b.item_type,2,b.qty*-1,b.qty)) qty,sum(decode(b.item_type,2,b.qty*-1,b.qty)*decode(a.use_vat,1,b.price, b.price+b.tax_amt+b.tax2_amt)) val
	from rps.document a,rps.document_item b
	where a.sid=b.doc_sid and  a.receipt_type in (0,1) and b.item_type in (1,2) and  a.status=4 and
	=-=cast(a.invc_post_date as date)=-=
	group by a.sbs_no,a.store_sid,b.invn_sbs_item_sid) sal
	on s.sbs_no=sal.sbs_no and iq.store_sid=sal.store_sid and iq.invn_sbs_item_sid=sal.invn_sbs_item_sid
	left join (select a.sbs_no,a.store_sid,b.invn_sbs_item_sid,
	sum(decode(b.item_type,2,b.qty*-1,b.qty)) qty,sum(decode(b.item_type,2,b.qty*-1,b.qty)*decode(a.use_vat,1,b.price, b.price+b.tax_amt+b.tax2_amt)) val
	from rps.document a,rps.document_item b
	where a.sid=b.doc_sid and  a.receipt_type in (0,1) and b.item_type in (1,2) and  a.status=4 and
	=-=cast(a.Invc_Post_Date as date)=-=
	group by a.sbs_no,a.store_sid,b.invn_sbs_item_sid) sal2
	on s.sbs_no=sal2.sbs_no and iq.store_sid=sal2.store_sid and iq.invn_sbs_item_sid=sal2.invn_sbs_item_sid
	where 1=1 and =-=s.sbs_no=-=
	group by s.sbs_no,st.store_no,st.store_code,d.dcs_code
order by s.sbs_no,st.store_no,st.store_code,d.dcs_code

