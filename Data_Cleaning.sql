-- Cleaning data in SQL queries

select * 
from PortfolioPj..NashvilleHousing

-- Standardize Data Format
select Convert(date, SaleDate)
from PortfolioPj..NashvilleHousing

Update NashvilleHousing 
set SaleDate = Convert(date, SaleDate)

Alter table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing 
set SaleDateConverted = Convert(date, SaleDate)

select * 
from PortfolioPj..NashvilleHousing

Alter table NashvilleHousing
drop column SaleDate;


--Filling Null Address
update a 
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioPj..NashvilleHousing a join PortfolioPj..NashvilleHousing b   
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

--Segmentize address into (Address, City, State)
Select PropertyAddress
from PortfolioPj..NashvilleHousing

select
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
from PortfolioPj..NashvilleHousing

alter table PortfolioPj..NashvilleHousing
add Property_Home_Address nvarchar(255)

alter table PortfolioPj..NashvilleHousing
add Property_City_Address nvarchar(255)

update NashvilleHousing
set Property_Home_Address = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
from PortfolioPj..NashvilleHousing

update NashvilleHousing
set Property_City_Address = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))
from PortfolioPj..NashvilleHousing

select * 
from PortfolioPj..NashvilleHousing

--Segmentizing owner's address
select owneraddress
from PortfolioPj..NashvilleHousing

select PARSENAME(replace(owneraddress, ',', '.'), 3), 
PARSENAME(replace(owneraddress, ',', '.'), 2), 
PARSENAME(replace(owneraddress, ',', '.'), 1)
from PortfolioPj..NashvilleHousing


alter table PortfolioPj..NashvilleHousing
add Owner_Home_Address nvarchar(255)

alter table PortfolioPj..NashvilleHousing
add Owner_City_Address nvarchar(255)

alter table PortfolioPj..NashvilleHousing
add Owner_State_Address nvarchar(255)

update PortfolioPj..NashvilleHousing
set Owner_Home_Address = PARSENAME(replace(owneraddress, ',', '.'), 3)

update PortfolioPj..NashvilleHousing
set Owner_City_Address = PARSENAME(replace(owneraddress, ',', '.'), 2)

update PortfolioPj..NashvilleHousing
set Owner_State_Address = PARSENAME(replace(owneraddress, ',', '.'), 1)

select * 
from PortfolioPj..NashvilleHousing

--Decoding 'SoldAsVacant' Yes and No to Y and N

select Soldasvacant,
case
when SoldAsVacant = 'Yes' then 'Y'
when SoldAsVacant = 'No' then 'N'
else SoldAsVacant
end
from PortfolioPj..NashvilleHousing

alter table PortfolioPj..NashvilleHousing
add Modified_Sold_As_Vacant CHAR(1)

update PortfolioPj..NashvilleHousing
set Modified_Sold_As_Vacant = case
							when SoldAsVacant = 'Yes' then 'Y'
							when SoldAsVacant = 'No' then 'N'
							else SoldAsVacant
							end

select * 
from PortfolioPj..NashvilleHousing

--Remove duplicate rows
select *, ROW_NUMBER () OVER
(Partition by ParcelID,
			   PropertyAddress,
			   SalePrice,
			   LegalReference,
			   Modified_Sold_As_Vacant
			   Order by UniqueId) row_num
from PortfolioPj..NashvilleHousing

--Create CTE
With row_num_cte as (
select *, ROW_NUMBER () OVER
(Partition by ParcelID,
			   PropertyAddress,
			   SalePrice,
			   LegalReference,
			   Modified_Sold_As_Vacant
			   Order by UniqueId) row_num
from PortfolioPj..NashvilleHousing
)
delete
from row_num_cte
where row_num > 1

With row_num_cte as (
select *, ROW_NUMBER () OVER
(Partition by ParcelID,
			   PropertyAddress,
			   SalePrice,
			   LegalReference,
			   Modified_Sold_As_Vacant
			   Order by UniqueId) row_num
from PortfolioPj..NashvilleHousing
)
select *
from row_num_cte
where row_num > 1

--delete unused columns

alter table portfoliopj..nashvillehousing
drop column PropertyAddress, OwnerAddress, TaxDistrict

alter table portfoliopj..nashvillehousing
drop column SoldAsVacant

select * from PortfolioPj..NashvilleHousing

	
