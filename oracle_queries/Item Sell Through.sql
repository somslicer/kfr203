select st.store_no,st.store_code,d.dcs_code dcs,
i.alu,to_char(i.upc) UPC,i.description1,i.description2,i.attribute,i.item_size,i.LAST_SOLD_DATE,
sum(nvl(iq.qty,0)) CURRENT_ON_HAND,
((sum(nvl(iq.qty,0))+sum(nvl(sal1.qty,0))-sum(nvl(vou1.qty,0))-sum(nvl(adj1.qty,0))+sum(nvl(sli1.qty,0)))
+sum(nvl(sal.qty,0))-sum(nvl(vou.qty,0))-sum(nvl(adj.qty,0))+sum(nvl(sli.qty,0))) Opening_ONHAND,
sum(nvl(sal.qty,0)) SOLD_QTY,
sum(nvl(vou.qty,0)) VOU_QTY,
sum(nvl(sli.qty,0)) SLIP_QTY,
sum(nvl(adj.qty,0)) ADJ_QTY,
sum(nvl(iq.qty,0))+sum(nvl(sal1.qty,0))-sum(nvl(vou1.qty,0))-sum(nvl(adj1.qty,0))+sum(nvl(sli1.qty,0)) Closing_ONHAND,
round(decode(((sum(nvl(iq.qty,0))+nvl(sum(sal1.qty),0)-nvl(sum(vou1.qty),0)-nvl(sum(adj1.qty),0)+nvl(sum(sli1.qty),0))
+nvl(sum(sal.qty),0)-nvl(sum(vou.qty),0)-nvl(sum(adj.qty),0)+nvl(sum(sli.qty),0)),0,0,nvl(sum(sal.qty),0)/((sum(nvl(iq.qty,0))+nvl(sum(sal1.qty),0)-nvl(sum(vou1.qty),0)-nvl(sum(adj1.qty),0)+nvl(sum(sli1.qty),0))
+nvl(sum(sal.qty),0)-nvl(sum(vou.qty),0)-nvl(sum(adj.qty),0)+nvl(sum(sli.qty),0))),2)*100 "SELL_THRU%",
round(decode(nvl(sum(sal.qty),0),0,0,round(((sum(nvl(iq.qty,0))+nvl(sum(sal1.qty),0)-nvl(sum(vou1.qty),0)-nvl(sum(adj1.qty),0)+nvl(sum(sli1.qty),0))
+nvl(sum(sal.qty),0)-nvl(sum(vou.qty),0)-nvl(sum(adj.qty),0)+nvl(sum(sli.qty),0)),0)/nvl(sum(sal.qty),0)),2) Stock_to_Sales
from rps.invn_sbs_item i
join rps.invn_sbs_item_qty iq
on i.sid=iq.invn_sbs_item_sid and i.sbs_sid=iq.sbs_sid
join rps.subsidiary s
on i.sbs_sid=s.sid
join rps.store st
on iq.sbs_sid=st.sbs_sid and iq.store_sid=st.sid
join rps.dcs d
on i.sbs_sid=d.sbs_sid and i.dcs_sid=d.sid
left join
(select a.sbs_no,a.store_no,b.invn_sbs_item_sid,
sum(decode(b.item_type,2,b.qty*-1,b.qty)) qty
from rps.document a,rps.document_item b,rps.subsidiary s,rps.store st
where a.sid=b.doc_sid and a.is_held=0 and a.receipt_type in (0,1) and  a.status=4 
and b.item_type in (1,2) and a.sbs_no=s.sbs_no and a.store_no=st.store_no and st.sbs_sid=s.sid
and =-=s.sbs_no=-= and =-=st.store_no=-=
and =-=trunc(a.Created_datetime)=-=  
group by a.sbs_no,a.store_no,b.invn_sbs_item_sid
) sal1
on s.sbs_no=sal1.sbs_no and st.store_no=sal1.store_no and iq.invn_sbs_item_sid=sal1.invn_sbs_item_sid
left join
(select a.sbs_no,a.store_no,b.invn_sbs_item_sid,
sum(decode(b.item_type,2,b.qty*-1,b.qty)) qty
from rps.document a,rps.document_item b,rps.subsidiary s,rps.store st
where a.sid=b.doc_sid and a.is_held=0 and a.receipt_type in (0,1) and  a.status=4 
and b.item_type in (1,2) and a.sbs_no=s.sbs_no and a.store_no=st.store_no and st.sbs_sid=s.sid
and =-=s.sbs_no=-= and =-=st.store_no=-=
and =-=trunc(a.created_datetime)=-= 
group by a.sbs_no,a.store_no,b.invn_sbs_item_sid
) sal
on s.sbs_no=sal.sbs_no and st.store_no=sal.store_no and iq.invn_sbs_item_sid=sal.invn_sbs_item_sid
left join
(select s.sbs_no,st.store_no,b.item_sid,sum(decode(a.vou_type,1,b.qty*-1,b.qty)) qty
from rps.voucher a,rps.vou_item b,rps.subsidiary s,rps.store st
where a.sid=b.vou_sid --and a.status=3 
and a.vou_type in (0,1)
and a.vou_class=0 and a.slip_flag=0 and a.held=0 and  st.sbs_sid=s.sid
and a.sbs_sid=s.sid and a.sbs_sid=st.sbs_sid and a.store_sid=st.sid
and =-=s.sbs_no=-= and =-=st.store_no=-=
and =-=trunc(a.Created_datetime)=-= 
group by s.sbs_no,st.store_no,b.item_sid
) vou1
on s.sbs_no=vou1.sbs_no and st.store_no=vou1.store_no and iq.invn_sbs_item_sid=vou1.item_sid 
left join
(select s.sbs_no,st.store_no,b.item_sid,sum(decode(a.vou_type,1,b.qty*-1,b.qty)) qty
from rps.voucher a,rps.vou_item b,rps.subsidiary s,rps.store st
where a.sid=b.vou_sid --and a.status=3 
and a.vou_type in (0,1)
and a.vou_class=0 and a.slip_flag=0 and a.held=0 and st.sbs_sid=s.sid
and a.sbs_sid=s.sid and a.sbs_sid=st.sbs_sid and a.store_sid=st.sid
and =-=s.sbs_no=-= and =-=st.store_no=-=
and =-=trunc(a.created_datetime)=-= 
group by s.sbs_no,st.store_no,b.item_sid
) vou
on s.sbs_no=vou.sbs_no and st.store_no=vou.store_no and iq.invn_sbs_item_sid=vou.item_sid 
left join
( select s.sbs_no,st.store_no,b.item_sid,sum(b.qty) qty
 FROM rps.SLIP A,rps.SLIP_ITEM B,rps.subsidiary s,rps.store st 
where A.SID=B.SLIP_SID --and a.STATUS=0 
and a.HELD=0  and st.sbs_sid=s.sid
and a.out_sbs_sid=s.sid and s.sid=st.sbs_sid and a.out_store_sid=st.sid
and =-=s.sbs_no=-= and =-=st.store_no=-=
and =-=trunc(a.Created_datetime)=-= 
 group by s.sbs_no,st.store_no,b.item_sid
) sli1
on s.sbs_no=sli1.sbs_no and st.store_no=sli1.store_no and iq.invn_sbs_item_sid=sli1.item_sid 
left join
( select s.sbs_no,st.store_no,b.item_sid,sum(b.qty) qty
 FROM rps.SLIP A,rps.SLIP_ITEM B,rps.subsidiary s,rps.store st 
where A.SID=B.SLIP_SID --and a.STATUS=0 
and a.HELD=0 
and a.out_sbs_sid=s.sid and s.sid=st.sbs_sid and a.out_store_sid=st.sid and st.sbs_sid=s.sid
and =-=s.sbs_no=-= and =-=st.store_no=-=
and =-=trunc(a.created_datetime)=-= 
 group by s.sbs_no,st.store_no,b.item_sid
) sli
on s.sbs_no=sli.sbs_no and st.store_no=sli.store_no and iq.invn_sbs_item_sid=sli.item_sid 
left join
(select s.sbs_no,st.store_no,b.item_sid,sum(adj_value-orig_value) qty
 from rps.Adjustment a,rps.adj_item b,rps.subsidiary s,rps.store st
where a.sid=b.adj_sid and a.adj_type=0 and s.sbs_no>=0 and a.HELD=0 and st.sbs_sid=s.sid
and =-=s.sbs_no=-= and =-=st.store_no=-=
and =-=trunc(a.Created_datetime)=-= 
and a.sbs_sid=s.sid and s.sid=st.sbs_sid and a.store_sid=st.sid
 group by s.sbs_no,st.store_no,b.item_sid) adj1
on s.sbs_no=adj1.sbs_no and st.store_no=adj1.store_no and iq.invn_sbs_item_sid=adj1.item_sid 
left join
(select s.sbs_no,st.store_no,b.item_sid,sum(adj_value-orig_value) qty
 from rps.Adjustment a,rps.adj_item b,rps.subsidiary s,rps.store st
where a.sid=b.adj_sid and a.adj_type=0 and s.sbs_no>=0 and a.HELD=0 and st.sbs_sid=s.sid
and =-=s.sbs_no=-= and =-=st.store_no=-=
and =-=trunc(a.created_datetime)=-= 
and a.sbs_sid=s.sid and s.sid=st.sbs_sid and a.store_sid=st.sid
 group by s.sbs_no,st.store_no,b.item_sid) adj
on s.sbs_no=adj.sbs_no and st.store_no=adj.store_no and iq.invn_sbs_item_sid=adj.item_sid 
where 1=1
and  =-=s.sbs_no=-= and =-=st.store_no=-=
group by st.store_no,st.store_code,d.dcs_code,
i.alu,i.upc,i.description1,i.description2,i.attribute,i.item_size,i.LAST_SOLD_DATE