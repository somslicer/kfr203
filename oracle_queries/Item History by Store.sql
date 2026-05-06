WITH 
common_cmpqty (sbs_sid, itemsid, Qty) AS (
    SELECT 
        sbs_sid, 
        invn_sbs_item_sid AS itemsid, 
        SUM(Qty) AS Qty
    FROM rps.INVN_SBS_ITEM_QTY INQ1 
    GROUP BY sbs_sid, invn_sbs_item_sid
),
common_plv (sbs_sid, itemsid, Price) AS (
    SELECT 
        isp.sbs_sid, 
        isp.invn_sbs_item_sid AS itemsid, 
        Price
    FROM rps.Invn_Sbs_Price Isp
    JOIN rps.price_level pl ON isp.price_lvl_sid = pl.sid
    WHERE pl.price_lvl = 1
),
sales AS (
    SELECT 
        S.SBS_NO, 
        ST.STORE_CODE, 
        INV.UPC, 
        INV.ALU, 
        INV.DESCRIPTION1, 
        INV.DESCRIPTION2, 
        INV.ATTRIBUTE, 
        INV.ITEM_SIZE, 
        'SALES' As Transaction_Type,
		trunc(a.Created_datetime) AS CREATED_DATE, 
        A.DOC_NO TRANSACTION_NO, 
        -Sum(B.Qty) As "DOC QTY",
        ROUND(Sum(Inq.Qty),0) As "STORE QTY", 
        Round(Sum(Inv.Cost * Inq.Qty),2) As "STORE EXT COST",
        Round(Sum(Inq.Qty * Plv.Price),2) As "STORE EXT PRICE",
        Round(Sum(Coalesce(Cmpqty.Qty, 0)),0) As "CMP QTY", 
        Round(Sum(Coalesce(Cmpqty.Qty, 0) * Inv.Cost),2) As "CMP EXT COST",
        ROUND(SUM(COALESCE(cmpqty.qty, 0) * PLV.PRICE),2) AS "CMP EXT PRICE"
    FROM rps.document a
    JOIN rps.document_item b ON a.sid = b.doc_sid
    JOIN rps.store st ON st.store_code = a.store_code 
    JOIN Rps.Subsidiary S On St.Sbs_Sid = S.Sid
    JOIN Rps.Invn_Sbs_Item Inv On Inv.Sid = B.Invn_Sbs_Item_Sid
    JOIN rps.INVN_SBS_ITEM_QTY INQ ON b.invn_sbs_item_sid = inq.invn_sbs_item_sid AND st.sid = inq.store_sid
    LEFT JOIN common_cmpqty cmpqty ON inv.sid = cmpqty.itemsid AND st.sbs_sid = cmpqty.sbs_sid
    LEFT JOIN common_plv plv ON plv.itemsid = inv.sid AND plv.sbs_sid = st.sbs_sid
    WHERE a.is_held = 0
      AND a.receipt_type IN (0)
      AND a.status = 4
      AND B.Item_Type IN (1)
	  and =-=s.sbs_no=-= and =-=st.store_no=-= and =-=st.store_code=-= and =-=Date(a.Created_datetime)=-= 
    GROUP BY s.sbs_no, st.store_code, a.Created_datetime, a.doc_no, 
             inv.upc, inv.alu, inv.description1, inv.description2, 
             inv.attribute, inv.item_size
),
salesret AS (
    SELECT 
        S.SBS_NO, 
        ST.STORE_CODE, 
        INV.UPC, 
        INV.ALU, 
        INV.DESCRIPTION1, 
        INV.DESCRIPTION2, 
        INV.ATTRIBUTE, 
        INV.ITEM_SIZE, 
		'RETURN' AS TRANSACTION_TYPE,
		trunc(a.Created_datetime) AS CREATED_DATE, 
        A.DOC_NO TRANSACTION_NO, 
        SUM(b.qty) AS "DOC QTY",
        ROUND(Sum(Inq.Qty),0) As "STORE QTY", 
        Round(Sum(Inv.Cost * Inq.Qty),2) As "STORE EXT COST",
        Round(Sum(Inq.Qty * Plv.Price),2) As "STORE EXT PRICE",
        Round(Sum(Coalesce(Cmpqty.Qty, 0)),0) As "CMP QTY", 
        Round(Sum(Coalesce(Cmpqty.Qty, 0) * Inv.Cost),2) As "CMP EXT COST",
        ROUND(SUM(COALESCE(cmpqty.qty, 0) * PLV.PRICE),2) AS "CMP EXT PRICE"
    FROM rps.document a
    JOIN rps.document_item b ON a.sid = b.doc_sid
    JOIN rps.store st ON st.store_code = a.store_code 
    JOIN Rps.Subsidiary S On St.Sbs_Sid = S.Sid
    JOIN Rps.Invn_Sbs_Item Inv On Inv.Sid = B.Invn_Sbs_Item_Sid
    JOIN rps.INVN_SBS_ITEM_QTY INQ ON b.invn_sbs_item_sid = inq.invn_sbs_item_sid AND st.sid = inq.store_sid
    LEFT JOIN common_cmpqty cmpqty ON inv.sid = cmpqty.itemsid AND st.sbs_sid = cmpqty.sbs_sid
    LEFT JOIN common_plv plv ON plv.itemsid = inv.sid AND plv.sbs_sid = st.sbs_sid
    WHERE a.is_held = 0
      AND a.receipt_type IN (1)
      AND a.status = 4
      AND B.Item_Type IN (2)
	  and =-=s.sbs_no=-= and =-=st.store_no=-= and =-=st.store_code=-= and =-=Date(a.Created_datetime)=-= 
    GROUP BY s.sbs_no, st.store_code, a.Created_datetime, a.doc_no, 
             inv.upc, inv.alu, inv.description1, inv.description2, 
             inv.attribute, inv.item_size
),
receiving AS (
    SELECT 
        S.SBS_NO, 
        ST.STORE_CODE, 
        INV.UPC, 
        INV.ALU, 
        INV.DESCRIPTION1, 
        INV.DESCRIPTION2, 
        INV.ATTRIBUTE, 
        INV.ITEM_SIZE, 
        'RECEIVING' AS transaction_type,
		trunc(a.Created_datetime) AS CREATED_DATE, 
        A.VOU_NO TRANSACTION_NO, 
        SUM(CASE WHEN a.vou_type = 1 THEN b.qty * -1 ELSE b.qty END) AS "DOC QTY",
        ROUND(Sum(Inq.Qty),0) As "STORE QTY", 
        Round(Sum(Inv.Cost * Inq.Qty),2) As "STORE EXT COST",
        Round(Sum(Inq.Qty * Plv.Price),2) As "STORE EXT PRICE",
        Round(Sum(Coalesce(Cmpqty.Qty, 0)),0) As "CMP QTY", 
        Round(Sum(Coalesce(Cmpqty.Qty, 0) * Inv.Cost),2) As "CMP EXT COST",
        ROUND(SUM(COALESCE(cmpqty.qty, 0) * PLV.PRICE),2) AS "CMP EXT PRICE"
    FROM rps.voucher a
    JOIN rps.vou_item b ON a.sid = b.vou_sid
    JOIN rps.store st ON a.store_sid = st.sid
    JOIN Rps.Subsidiary S On St.Sbs_Sid = S.Sid
    JOIN Rps.Invn_Sbs_Item Inv On Inv.Sbs_Sid = A.Sbs_Sid And Inv.Sid = B.Item_Sid
    JOIN rps.INVN_SBS_ITEM_QTY INQ ON inq.invn_sbs_item_sid = b.item_sid AND st.sid = inq.store_sid
    LEFT JOIN common_cmpqty cmpqty ON inv.sid = cmpqty.itemsid AND st.sbs_sid = cmpqty.sbs_sid
    LEFT JOIN common_plv plv ON plv.itemsid = inv.sid AND plv.sbs_sid = st.sbs_sid
    WHERE a.status = 4
      AND a.vou_type IN (0, 1)
      AND a.vou_class = 0
      AND a.slip_flag = 0
      AND a.held = 0
      And A.Proc_Status Not In (16, 32)
	  and =-=s.sbs_no=-= and =-=st.store_no=-= and =-=st.store_code=-= and =-=Date(a.Created_datetime)=-= 
    GROUP BY s.sbs_no, st.store_code, a.Created_datetime, a.vou_no, 
             inv.upc, inv.alu, inv.description1, inv.description2, 
             Inv.Attribute, Inv.Item_Size
),
transfer_out AS (
    SELECT 
        S.SBS_NO, ST.STORE_CODE,  INV.UPC, INV.ALU, INV.DESCRIPTION1, INV.DESCRIPTION2, INV.ATTRIBUTE, INV.ITEM_SIZE, 
		'TRANSFER OUT' AS transaction_type,
		trunc(a.Created_datetime) AS CREATED_DATE, A.SLIP_NO TRANSACTION_NO,
		-SUM(b.qty) AS "DOC QTY",
        ROUND(Sum(Inq.Qty),0) As "STORE QTY", 
        Round(Sum(Inv.Cost * Inq.Qty),2) As "STORE EXT COST",
        Round(Sum(Inq.Qty * Plv.Price),2) As "STORE EXT PRICE",
        Round(Sum(Coalesce(Cmpqty.Qty, 0)),0) As "CMP QTY", 
        Round(Sum(Coalesce(Cmpqty.Qty, 0) * Inv.Cost),2) As "CMP EXT COST",
        ROUND(SUM(COALESCE(cmpqty.qty, 0) * PLV.PRICE),2) AS "CMP EXT PRICE"
    FROM rps.SLIP a
    JOIN rps.SLIP_ITEM b ON a.SID = b.SLIP_SID
    JOIN rps.store st ON a.out_store_sid = st.sid
    JOIN Rps.Subsidiary S ON St.Sbs_Sid = S.Sid
    JOIN Rps.Invn_Sbs_Item Inv ON Inv.Sbs_Sid = A.Out_Sbs_Sid And Inv.Sid = B.Item_Sid
    JOIN rps.INVN_SBS_ITEM_QTY INQ ON b.item_sid = inq.invn_sbs_item_sid AND st.sid = inq.store_sid
    LEFT JOIN common_cmpqty cmpqty ON inv.sid = cmpqty.itemsid AND st.sbs_sid = cmpqty.sbs_sid
    LEFT JOIN common_plv plv ON plv.itemsid = inv.sid AND plv.sbs_sid = st.sbs_sid
    WHERE a.STATUS = 4
      AND a.HELD = 0
      AND A.Proc_Status NOT IN (16, 32)
	  and =-=s.sbs_no=-= and =-=st.store_no=-= and =-=st.store_code=-= and =-=Date(a.Created_datetime)=-= 
    Group By S.Sbs_No, St.Store_Code, A.Created_Datetime, A.Slip_No, Inv.Upc, Inv.Alu, Inv.Description1, Inv.Description2, Inv.Attribute, Inv.Item_Size
),
transfer_in AS (
    SELECT 
        S.SBS_NO, ST.STORE_CODE, INV.UPC, INV.ALU, INV.DESCRIPTION1, INV.DESCRIPTION2, INV.ATTRIBUTE, INV.ITEM_SIZE, 
		'TRANSFER IN' AS transaction_type,
		trunc(a.Created_datetime) AS CREATED_DATE, A.VOU_NO TRANSACTION_NO,
        SUM(CASE WHEN a.vou_type = 1 THEN b.qty * -1 ELSE b.qty END) AS "DOC QTY",
        ROUND(Sum(Inq.Qty),0) As "STORE QTY", 
        Round(Sum(Inv.Cost * Inq.Qty),2) As "STORE EXT COST",
        Round(Sum(Inq.Qty * Plv.Price),2) As "STORE EXT PRICE",
        Round(Sum(Coalesce(Cmpqty.Qty, 0)),0) As "CMP QTY", 
        Round(Sum(Coalesce(Cmpqty.Qty, 0) * Inv.Cost),2) As "CMP EXT COST",
        ROUND(SUM(COALESCE(cmpqty.qty, 0) * PLV.PRICE),2) AS "CMP EXT PRICE"
    FROM rps.voucher a
    JOIN rps.vou_item b ON a.sid = b.vou_sid
    JOIN rps.store st ON a.store_sid = st.sid
    JOIN Rps.Subsidiary S ON St.Sbs_Sid = S.Sid
    JOIN Rps.Invn_Sbs_Item Inv ON Inv.Sbs_Sid = A.Sbs_Sid And Inv.Sid = B.Item_Sid
    JOIN rps.INVN_SBS_ITEM_QTY INQ ON b.item_sid = inq.invn_sbs_item_sid AND st.sid = inq.store_sid
    LEFT JOIN common_cmpqty cmpqty ON inv.sid = cmpqty.itemsid AND st.sbs_sid = cmpqty.sbs_sid
    LEFT JOIN common_plv plv ON plv.itemsid = inv.sid AND plv.sbs_sid = st.sbs_sid
    WHERE a.status = 4
      AND a.vou_type IN (0, 1)
      AND a.vou_class = 0
      AND a.slip_flag = 1
      AND a.held = 0
      AND A.Proc_Status NOT IN (16, 32)
	  and =-=s.sbs_no=-= and =-=st.store_no=-= and =-=st.store_code=-= and =-=Date(a.Created_datetime)=-= 
    Group By S.Sbs_No, St.Store_Code, A.Created_Datetime, A.Vou_No, Inv.Upc, Inv.Alu, Inv.Description1, Inv.Description2, Inv.Attribute, Inv.Item_Size
),
adjust AS (
    SELECT 
        S.SBS_NO, ST.STORE_CODE, INV.UPC, INV.ALU, INV.DESCRIPTION1, INV.DESCRIPTION2, INV.ATTRIBUTE, INV.ITEM_SIZE, 
		'ADJUSTMENT' AS transaction_type,
		trunc(a.Created_datetime) AS CREATED_DATE, A.ADJ_NO TRANSACTION_NO, 
        SUM(b.adj_value - b.orig_value) AS "DOC QTY",
        ROUND(Sum(Inq.Qty),0) As "STORE QTY", 
        Round(Sum(Inv.Cost * Inq.Qty),2) As "STORE EXT COST",
        Round(Sum(Inq.Qty * Plv.Price),2) As "STORE EXT PRICE",
        Round(Sum(Coalesce(Cmpqty.Qty, 0)),0) As "CMP QTY", 
        Round(Sum(Coalesce(Cmpqty.Qty, 0) * Inv.Cost),2) As "CMP EXT COST",
        ROUND(SUM(COALESCE(cmpqty.qty, 0) * PLV.PRICE),2) AS "CMP EXT PRICE"
    FROM rps.Adjustment a
    JOIN rps.adj_item b ON a.sid = b.adj_sid
    JOIN rps.store st ON a.store_sid = st.sid
    JOIN Rps.Subsidiary S ON St.Sbs_Sid = S.Sid
    JOIN Rps.Invn_Sbs_Item Inv ON Inv.Sid = B.Item_Sid
    JOIN rps.INVN_SBS_ITEM_QTY INQ ON b.item_sid = inq.invn_sbs_item_sid AND st.sid = inq.store_sid
    LEFT JOIN common_cmpqty cmpqty ON inv.sid = cmpqty.itemsid AND st.sbs_sid = cmpqty.sbs_sid
    LEFT JOIN common_plv plv ON plv.itemsid = inv.sid AND plv.sbs_sid = st.sbs_sid
    WHERE a.adj_type = 0
      AND A.Held = 0
	  and =-=s.sbs_no=-= and =-=st.store_no=-= and =-=st.store_code=-= and =-=Date(a.Created_datetime)=-= 
    Group By S.Sbs_No, St.Store_Code, A.Created_Datetime, A.Adj_No, Inv.Upc, Inv.Alu, Inv.Description1, Inv.Description2, Inv.Attribute, Inv.Item_Size
)
SELECT * FROM sales
UNION ALL
SELECT * FROM salesret
UNION ALL
Select * From Receiving
Union All
Select * From Transfer_Out
Union All
Select * From Transfer_In 
Union All
SELECT * FROM ADJUST 
