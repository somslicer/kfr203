select * from (
select s.sbs_no, st.store_no,st.store_code, d.dcs_code dcs,
i.alu,to_char(i.upc) upc,i.description1,i.description2,i.attribute,i.item_size,i.last_rcvd_date Last_Received_date,
sum(iq.qty) On_Hand,round(sum(iq.qty*nvl(ip.price,0)),2) On_Hand_Value,i.last_sold_date,
sum(nvl(sal.qty,0)) Sold_qty,round(sum(nvl(sal.val,0)),2) Net_Sold_Value_W_Tax,
dense_rank() over(partition by s.sbs_no, st.store_no order by sum(iq.qty) asc) Rank 
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
left join (select a.sbs_no,a.store_sid,b.invn_sbs_item_sid,
sum(decode(b.item_type,2,b.qty*-1,b.qty)) qty,sum(decode(b.item_type,2,b.qty*-1,b.qty)* decode(a.use_vat,1,b.price, b.price+b.tax_amt+b.tax2_amt)) val
from rps.document a,rps.document_item b
where a.sid=b.doc_sid and  a.receipt_type in (0,1) and b.item_type in (1,2) and  a.status=4 and
=-=cast(a.invc_post_date as date)=-=
group by a.sbs_no,a.store_sid,b.invn_sbs_item_sid) sal
on s.sbs_no=sal.sbs_no and iq.store_sid=sal.store_sid and iq.invn_sbs_item_sid=sal.invn_sbs_item_sid
group by s.sbs_no, st.store_no,st.store_code,d.dcs_code,
i.alu,i.upc,i.description1,i.description2,i.attribute,i.item_size,i.last_sold_date,i.last_rcvd_date
) aa
where 1=1 and =-=ranks=-=