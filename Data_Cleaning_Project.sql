/*

cleaning data in SQL Queries

*/



select* 
from cleaning..housing



-- standardize date format

select saledate2,CONVERT(Date,saledate)
from cleaning..housing


update Housing
set saledate = CONVERT(Date,saledate)

alter table housing
add saledate2 date;

update Housing
set saledate2 = CONVERT(Date,saledate)


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address data

select *
from cleaning..housing 
--where propertyaddress is null
order by parcelid



select a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress,ISNULL(a.propertyaddress,b.propertyaddress)
from cleaning..housing a
join cleaning..housing b
     on a.parcelid=b.parcelid
	 and a.[Uniqueid]!= b.[uniqueid]
where a.propertyaddress is null   


update a
set propertyaddress = ISNULL(a.propertyaddress,b.propertyaddress)
from cleaning..housing a
join cleaning..housing b
     on a.parcelid=b.parcelid
	 and a.[Uniqueid]!= b.[uniqueid]
	 where a.propertyaddress is null 


-------------------------------------------------------------------------------------------------


-- Breaking out address into Individual column (Address,city,state)

select propertyaddress
from cleaning..housing 
--where propertyaddress is null
--order by parcelid



select
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) as address,
SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, len(propertyaddress)) as address

from cleaning..housing 

alter table housing
add PropertySplit Nvarchar(255);

update Housing
set PropertySplit = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1)


alter table housing
add PropertyCity Nvarchar(255);

update Housing
set PropertyCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, len(propertyaddress))


select owneraddress
from cleaning..housing


select
PARSENAME(replace(owneraddress,',' , '.'), 3),
PARSENAME(replace(owneraddress,',' , '.'), 2),
PARSENAME(replace(owneraddress,',' , '.'), 1)
from cleaning..housing





alter table housing
add OwnerSplitAddress Nvarchar(255);

update Housing
set OwnerSplitAddress = PARSENAME(replace(owneraddress,',' , '.'), 3)


alter table housing
add OwnerSplitCity Nvarchar(255);

update Housing
set OwnerSplitCity = PARSENAME(replace(owneraddress,',' , '.'), 2)





alter table housing
add OwnerSplitState Nvarchar(255);

update Housing
set OwnerSplitState = PARSENAME(replace(owneraddress,',' , '.'), 1)


-------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(soldasvacant),count(soldasvacant)
from cleaning..housing
group by soldasvacant
order by 2



select soldasvacant,
case when soldasvacant = 'Y' then 'YES'
     when soldasvacant = 'N' then 'NO'
	 else soldasvacant
	 end
from cleaning..housing


update housing
set soldasvacant = case when soldasvacant = 'Y' then 'YES'
     when soldasvacant = 'N' then 'NO'
	 else soldasvacant
	 end


------------------------------------------------------------------------------------------------------------


-- Removing Duplicates


with RowNumCTE as (
select *,
    ROW_NUMBER() over (
	partition by parcelid,
	             propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by 
				     uniqueid
					 ) row_num
from cleaning..housing
--order by parcelid
)

Delete
from RowNumCTE
where row_num>1

----------------------------------------------------------------------------------------------------------------

-- Deleting Unused Columns

Alter table cleaning..housing
drop column owneraddress, taxdistrict,propertyaddress,saledate

select *
from cleaning..housing





