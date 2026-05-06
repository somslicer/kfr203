Select aa.sbs_no SBS_NO, dense_rank() over(partition by aa.sbs_no order by aa.sbs_no asc,sum(aa.EXTPT) desc) RANKS, aa.bt_id CUST_ID,  aa.bt_first_name "FIRST NAME",aa.bt_last_name "LAST NAME", aa.bt_address_line1 ADDRESS1,
aa.bt_address_line2 ADDRESS2,aa.bt_address_line3 ADDRESS3,aa.bt_postal_code POSTAL_CODE,aa.bt_email EMAIL, aa.bt_primary_phone_no "PHONE NO", aa.LAST_SALE_DATE, SUM(aa.sold_qty) SOLD_QTY, SUM(aa.Return_qty) RETURN_QTY,
round(sum(aa.EXTPT),2) SOLD_VALUE
from (
select a.sbs_no SBS_NO,
bt_id, bt_first_name,bt_last_name,bt_address_line1, b.dcs_code, b.vend_code, b.description1,
bt_address_line2,bt_address_line3,bt_postal_code,bt_email, bt_primary_phone_no, C.LAST_SALE_DATE, 
sum(CASE WHEN b.item_type = 2 THEN b.qty * -1 ELSE b.qty END) AS Sold_qty,
      sum(CASE WHEN b.item_type = 2 THEN b.qty * -1 ELSE 0 END) AS Return_qty,
    Sum(Round(((Case When B.Item_Type = 2 Then B.Qty * -1 Else B.Qty End) * (Case When A.Use_Vat=1 Then B.Price Else B.Price+B.Tax_Amt+B.Tax2_Amt End)),2)) Extpt
From Rps.Document A 
Join Rps.Document_Item B On A.Sid=B.Doc_Sid
join RPS.CUSTOMER c on c.sid=a.bt_cuid 
Where 1=1 And  A.Receipt_Type In (0,1) And  A.Status=4 And Bt_Id Is Not Null 
and =-=a.sbs_no=-= and =-=trunc(a.created_datetime)=-= and 
=-=b.dcs_code=-= and =-=b.vend_code=-= and =-=b.description1=-= and =-=trunc(C.LAST_SALE_DATE)=-=
group by a.sbs_no,bt_id ,
bt_first_name ,bt_last_name ,bt_address_line1 , b.dcs_code, b.vend_code, b.description1,
bt_address_line2 ,bt_address_line3 ,bt_postal_code,bt_email, bt_primary_phone_no, C.LAST_SALE_DATE
) aa
Where 1=1 
and =-=ranks=-= 
Group By Aa.Sbs_No, Aa.Bt_Id,  Aa.Bt_First_Name, Aa.Bt_Last_Name, Aa.Bt_Address_Line1,
aa.bt_address_line2, aa.bt_address_line3, aa.bt_postal_code, aa.bt_email, aa.bt_primary_phone_no, aa.LAST_SALE_DATE