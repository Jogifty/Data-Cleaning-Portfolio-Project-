--CLEANING DATA IN SQL QUERIES

select *
from PortfolioProject.dbo.NashvilleHousing

--STANDARDIZE DATE FORMAT 

select SaleDateConverted, CONVERT(date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

--Populate Property Address Table

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null 
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress ,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a 
set PropertyAddress= ISNULL(a.PropertyAddress ,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out Address into individual columns (address, city, state)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null 
--order by ParcelID

select 
SUBSTRING (PropertyAddress, 1, CHARINDEX ( ',', PropertyAddress) -1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX ( ',', PropertyAddress) +1,  len(PropertyAddress))as Address
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress  = SUBSTRING (PropertyAddress, 1, CHARINDEX ( ',', PropertyAddress) -1) 


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX ( ',', PropertyAddress) +1,  len(PropertyAddress))


select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select
parsename (replace (OwnerAddress,',', '.'), 3)
,parsename(replace  (OwnerAddress,',', '.'), 2)
,parsename(replace(OwnerAddress,',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename (replace (OwnerAddress,',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace  (OwnerAddress,',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress,',', '.'), 1)

select *
from PortfolioProject.dbo.NashvilleHousing

--Change Y and N to Yes and No in 'Sold Vacant' field

select distinct(SoldAsVacant),count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, CASE When SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   END
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant=  CASE When SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   END



--Remove Duplicates
With RowNumCTE AS (
select *,
   ROW_NUMBER() over(
	partition by ParcelID,
	             PropertyAddress,
				 Saleprice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				  UniqueID
				  ) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
Order by PropertyAddress



--Delete unused Columns

select * 
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
drop column SaleDate
