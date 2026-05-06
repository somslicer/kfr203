SELECT 
  st.store_no,
  st.store_code,
  d.dcs_code AS dcs,
  i.alu,
  TO_CHAR(i.upc) AS UPC,
  i.description1,
  i.description2,
  i.attribute,
  i.item_size,
v.vend_code, v.vend_name,
  TRUNC(i.LAST_SOLD_DATE) AS LAST_SOLD_DATE,
  NVL(iq.qty, 0) AS CURRENT_ON_HAND,
  delta.Opening_ONHAND,
  delta.SOLD_QTY,
  delta.VOU_QTY,
  delta.SLIP_QTY,
  delta.ADJ_QTY,
  delta.Closing_ONHAND,
  (nvl(intran.qty,0)) Intran_qty
FROM rps.invn_sbs_item i
JOIN rps.invn_sbs_item_qty iq ON i.sid =iq.invn_sbs_item_sid AND i.sbs_sid=iq.sbs_sid
JOIN rps.subsidiary s ON i.sbs_sid=s.sid
JOIN rps.store st ON iq.sbs_sid   =st.sbs_sid AND iq.store_sid=st.sid
LEFT JOIN RPS.vendor v ON v.sid = i.vend_sid   and i.sbs_sid=v.sbs_sid and s.sid=v.sbs_sid
JOIN rps.dcs d ON i.sbs_sid =d.sbs_sid AND i.dcs_sid=d.sid
JOIN (
   SELECT
    d1.sbs_no,
    d1.store_no,
    d1.item_sid,
    SUM(CASE WHEN d1.doc_open_rank = 1 THEN d1.open_Qty ELSE 0 END)  AS Opening_ONHAND,
    SUM(CASE WHEN d1.doc_type = 'SALE' THEN d1.qty ELSE 0 END) AS SOLD_QTY,
    SUM(CASE WHEN d1.doc_type = 'VOUCHER' THEN d1.qty * -1 ELSE 0 END) AS VOU_QTY,
    SUM(CASE WHEN d1.doc_type = 'SLIP' THEN d1.qty ELSE 0 END) AS SLIP_QTY,
    SUM(CASE WHEN d1.doc_type = 'ADJUSTMENT' THEN d1.qty * -1 ELSE 0 END) AS ADJ_QTY,
    SUM(CASE WHEN d1.doc_close_rank = 1 THEN d1.close_Qty ELSE 0 END) AS Closing_ONHAND
  FROM (
  SELECT
      d2.sbs_no, d2.store_no, d2.doc_type, d2.created_datetime,
      d2.item_sid, d2.open_Qty, d2.qty, d2.close_Qty,
      rank() OVER (PARTITION BY d2.sbs_no, d2.store_no, d2.item_sid ORDER BY d2.created_datetime) AS doc_open_rank,
      rank() OVER (PARTITION BY d2.sbs_no, d2.store_no, d2.item_sid ORDER BY d2.created_datetime DESC) AS doc_close_rank
  FROM(
    SELECT 
      d.sbs_no,
      d.store_no,
      d.doc_type,
      d.created_datetime,
      d.item_sid,
      SUM (d.qty) OVER (PARTITION BY d.sbs_no, d.store_no, d.item_sid ORDER BY d.created_datetime DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS open_Qty,
      d.qty,
      CASE WHEN DOC_TYPE ='INVN' THEN d.qty
          ELSE (SUM (d.qty) OVER (PARTITION BY d.sbs_no, d.store_no, d.item_sid ORDER BY d.created_datetime DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))  - d.qty 
          END AS close_Qty
    FROM (
      SELECT 
          s.sbs_no,
          st.store_no,
          'INVN' AS doc_type,
          (SYSTIMESTAMP) AS created_datetime,
          i.sid AS item_sid,
          NVL(iq.qty, 0) AS qty
      FROM rps.invn_sbs_item i
      JOIN rps.invn_sbs_item_qty iq ON i.sid =iq.invn_sbs_item_sid AND i.sbs_sid=iq.sbs_sid
      JOIN rps.subsidiary s ON i.sbs_sid=s.sid
      JOIN rps.store st ON iq.sbs_sid   =st.sbs_sid AND iq.store_sid=st.sid
      WHERE 1 = 1
      and =-=s.sbs_no=-= and =-=st.store_no=-=
      UNION ALL
      SELECT 
          a.sbs_no,
          a.store_no,
          'SALE' AS doc_type,
          (a.created_datetime) AS created_datetime,
          b.invn_sbs_item_sid AS item_sid,
          SUM(CASE WHEN b.item_type = 2 THEN b.qty * -1  ELSE b.qty END) qty
        FROM rps.document a
        JOIN rps.document_item b ON a.sid = b.doc_sid
        JOIN rps.subsidiary s ON s.sid = a.subsidiary_sid
        JOIN rps.store st ON st.sid = a.store_sid
        WHERE a.is_held = 0
        AND a.receipt_type IN (0,1)
        AND a.status = 4
        AND b.item_type IN (1,2)
        AND b.kit_flag NOT IN (2, 3)
          and =-=s.sbs_no=-= and =-=st.store_no=-=
      GROUP BY a.sbs_no,
          a.store_no,
          (a.created_datetime),
          b.invn_sbs_item_sid
      UNION ALL   
      SELECT s.sbs_no,
          st.store_no,
          'VOUCHER' AS doc_type,
          (a.created_datetime) AS created_datetime,
          b.item_sid,
          SUM(CASE WHEN a.vou_type = 1 THEN b.qty  ELSE b.qty *-1 END) qty
        FROM rps.voucher a
        JOIN rps.vou_item b ON a.sid = b.vou_sid
        JOIN rps.subsidiary s ON a.sbs_sid   =s.sid
        JOIN rps.store st ON a.store_sid =st.sid
        WHERE a.vou_type IN (0,1)
        AND a.vou_class in (0, 2)
        AND a.held      =0  
          and =-=s.sbs_no=-= and =-=st.store_no=-=
        GROUP BY s.sbs_no,
          st.store_no,
          (a.created_datetime),
          b.item_sid    
      UNION ALL
      SELECT s.sbs_no,
          st.store_no,
          'SLIP' AS doc_type,
          (a.created_datetime) AS created_datetime,
          b.item_sid,
          SUM(b.qty) qty
        FROM rps.SLIP a
         JOIN rps.SLIP_ITEM b ON a.sid        =b.slip_sid
         JOIN rps.subsidiary s ON a.out_sbs_sid  =s.sid
         JOIN rps.store st ON a.out_store_sid=st.sid
        WHERE a.HELD         =0
          and =-=s.sbs_no=-= and =-=st.store_no=-=
        GROUP BY s.sbs_no,
          st.store_no,
          (a.created_datetime),
          b.item_sid
      UNION ALL  
      SELECT s.sbs_no,
          st.store_no,
          'ADJUSTMENT' AS doc_type,
          (a.created_datetime) AS created_datetime,
          b.item_sid,
          SUM(NVL(adj_value,0)- NVL(orig_value,0)) * -1 AS qty
        FROM rps.Adjustment a
         JOIN rps.adj_item b ON a.sid   =b.adj_sid
         JOIN rps.subsidiary s ON a.sbs_sid  =s.sid
         JOIN rps.store st ON a.store_sid=st.sid
        WHERE a.adj_type=0
        AND s.sbs_no >=0
        AND a.HELD    =0
          and =-=s.sbs_no=-= and =-=st.store_no=-=
        GROUP BY s.sbs_no,
          st.store_no,
          (a.created_datetime),
          b.item_sid
           ) d
    )d2
     WHERE 1 = 1
  AND =-=TRUNC(d2.created_datetime)=-=
  ) d1
  GROUP BY   d1.sbs_no,
    d1.store_no,
    d1.item_sid
) delta ON delta.sbs_no = s.sbs_no AND delta.store_no = st.store_no AND delta.item_sid = iq.invn_sbs_item_sid
  LEFT JOIN (
    SELECT s.sbs_no, st.store_no, b.item_sid, SUM(CASE WHEN d2.vou_type = 1 THEN b.qty *-1 ELSE b.qty END) qty
      FROM rps.voucher d2 
      JOIN rps.vou_item b ON d2.sid = b.vou_sid 
      JOIN rps.subsidiary s ON d2.sbs_sid=s.sid
      JOIN rps.store st ON d2.sbs_sid = st.sbs_sid AND d2.store_sid = st.sid
     WHERE d2.vou_type in (0,1) AND d2.status=3
      AND d2.vou_class=2 AND d2.slip_flag=1 AND d2.held=0 AND d2.verified=0 AND d2.active=1
      AND =-=s.sbs_no=-= 
      AND =-=st.store_no=-=
      AND =-=TRUNC(d2.created_datetime)=-= 
      GROUP BY s.sbs_no,st.store_no,b.item_sid) intran
  ON s.sbs_no = intran.sbs_no AND st.store_no = intran.store_no AND iq.invn_sbs_item_sid = intran.item_sid
WHERE 1 = 1
 and =-=s.sbs_no=-= and =-=st.store_no=-=