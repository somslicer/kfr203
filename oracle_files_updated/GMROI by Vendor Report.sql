SELECT Sal.sbs_no SBS_NO, Sal.sbs_name SBS_NAME, Sal.vend_code VEND_CODE, Sal.LSQ "LAST SOLD QTY", Sal.LC "LAST EXT COST", sal.LOPT "LAST EXT ORIG PRICE W TAX",  Sal.LPT "LAST EXT PRICE W TAX", (Sal.LPT-Sal.LC) "LAST EXT MARGIN", round(case when Sal.LPT = 0 then 0 else (Sal.LPT - Sal.LC) /Sal.LPT * 100 end, 2) as "LAST MARGIN%",ROUND( CASE WHEN LC=0 THEN 0 ELSE (Sal.LOPT-Sal.LC)/(sal.LC) END,2) "LAST GMROI",
	Sal.CSQ "CURRENT SOLD QTY", Sal.CC "CURRENT EXT COST",sal.COPT "CURRENT EXT ORIG PRICE W TAX",   Sal.CPT "CURRENT EXT PRICE W TAX", (Sal.CPT-Sal.CC) "CURRENT EXT MARGIN", 		   round(case when Sal.CPT = 0 then 0 else (Sal.CPT - Sal.CC) /Sal.CPT * 100 end, 2) as "CURRENT MARGIN%",ROUND(CASE WHEN CC=0 THEN 0 ELSE (Sal.COPT-Sal.CC)/CC END,2) "CURRENT GMROI"
	from	   
	(select s.sbs_no, s.sbs_name, b.vend_code, sum(case when =-=cast(a.Invc_Post_Date as date)=-= then (CASE WHEN b.item_type = 2 THEN b.qty * -1 ELSE b.qty END)  else 0 end) LSQ,
	round(sum(case when =-=cast(a.Invc_Post_Date as date)=-= then (CASE WHEN b.item_type = 2 THEN b.qty * -1 ELSE b.qty END) *(CASE WHEN A.USE_VAT=1 THEN B.PRICE-B.TAX_AMT-B.TAX2_AMT ELSE B.PRICE END) else 0 end),2) LP,
	round(sum(case when =-=cast(a.Invc_Post_Date as date)=-= then (CASE WHEN b.item_type = 2 THEN b.qty * -1 ELSE b.qty END) * (CASE WHEN A.USE_VAT=1 THEN B.PRICE ELSE B.PRICE+B.TAX_AMT+B.TAX2_AMT END) else 0 end),2) LPT,
	round(sum(case when =-=cast(a.Invc_Post_Date as date)=-= then (CASE WHEN b.item_type = 2 THEN b.qty * -1 ELSE b.qty END) * (CASE WHEN A.USE_VAT=1 THEN B.ORIG_PRICE ELSE B.ORIG_PRICE+B.ORIG_TAX_AMT END) else 0 end),2) LOPT,
	round(sum(case when =-=cast(a.Invc_Post_Date as date)=-= then (CASE WHEN b.item_type = 2 THEN b.qty * -1 ELSE b.qty END) * (b.cost) else 0 end),2) LC,
	sum(case when =-=cast(a.invc_post_date as date)=-= then (CASE WHEN b.item_type = 2 THEN b.qty * -1 ELSE b.qty END)  else 0 end) CSQ,
	round(sum(case when =-=cast(a.invc_post_date as date)=-= then (CASE WHEN b.item_type = 2 THEN b.qty * -1 ELSE b.qty END) *(CASE WHEN A.USE_VAT=1 THEN B.PRICE-B.TAX_AMT-B.TAX2_AMT ELSE B.PRICE END) else 0 end),2) CP,
	round(sum(case when =-=cast(a.invc_post_date as date)=-= then (CASE WHEN b.item_type = 2 THEN b.qty * -1 ELSE b.qty END) *(CASE WHEN A.USE_VAT=1 THEN B.PRICE ELSE B.PRICE+B.TAX_AMT+B.TAX2_AMT END) else 0 end),2) CPT,
	round(sum(case when =-=cast(a.invc_post_date as date)=-= then (CASE WHEN b.item_type = 2 THEN b.qty * -1 ELSE b.qty END) *(CASE WHEN A.USE_VAT=1 THEN B.ORIG_PRICE ELSE B.ORIG_PRICE+B.ORIG_TAX_AMT END) else 0 end),2) COPT,
	round(sum(case when =-=cast(a.invc_post_date as date)=-= then (CASE WHEN b.item_type = 2 THEN b.qty * -1 ELSE b.qty END)  * (b.cost) else 0 end),2) CC,
	round(AVG(case when =-=cast(a.invc_post_date as date)=-= then b.cost else 0 end),2) CAC
	from rps.document a inner join 
	rps.document_item b on a.sid=b.doc_sid
	inner join rps.subsidiary s on a.sbs_no=s.sbs_no and b.sbs_no=s.sbs_no 
	inner join rps.dcs d on s.sid=d.sbs_sid and b.dcs_code=d.dcs_code
	inner join rps.invn_sbs_item i on b.invn_sbs_item_sid=i.sid and s.sid=i.sbs_sid
	left join rps.invn_sbs_extend it on i.sid=it.invn_sbs_item_sid
	where  1=1 and =-=s.sbs_no=-= and a.receipt_type in (0,1) and b.item_type in (1,2) and  a.status=4 and
	(=-=cast(a.Invc_Post_Date as date)=-=
	or =-=cast(a.invc_post_date as date)=-=
	)
	group by s.sbs_no, s.sbs_name, b.vend_code
	order by s.sbs_no, s.sbs_name, b.vend_code)
	Sal