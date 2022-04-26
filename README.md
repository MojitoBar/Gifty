# Gifty

<kbd>
  <img style="width: 80px;" src="https://user-images.githubusercontent.com/16567811/165350891-c031e405-518d-4606-8071-874a49159d73.png" alt="Gifty-Icon"/>
</kbd>
<br/><br/>

> Gifty - 갤러리의 숨은 기프티콘 <br>
> 갤러리에서 기프티콘 이미지만 뽑아 쉽게 관리할 수 있게 한 어플리케이션 입니다.
>
> RELEASE: 2022.04.21

<a href="https://apps.apple.com/kr/app/gifty/id1592949834"><img src="https://user-images.githubusercontent.com/28949235/146959188-28042fcf-2bd5-4ab2-a0d5-9d47d1b9a7ca.png" width=200></a>
<div>
  <img style="width: 160px;" src="https://user-images.githubusercontent.com/16567811/165349708-41b006f8-353f-4bcd-a6f9-af3605409f65.png" alt="Gifty-1"/>
  <img style="width: 160px;" src="https://user-images.githubusercontent.com/16567811/165350009-926759ec-1a32-4944-949b-59d01adae1db.png" alt="Gifty-2"/>
  <img style="width: 160px;" src="https://user-images.githubusercontent.com/16567811/165350017-ea0a9436-c6b1-4457-bca0-636b0e02c917.png" alt="Gifty-3"/>
  <img style="width: 160px;" src="https://user-images.githubusercontent.com/16567811/165350021-fc8060fa-ee56-4ff6-92eb-0bacec03f899.png" alt="Gifty-4"/>
  <img style="width: 160px;" src="https://user-images.githubusercontent.com/16567811/165350034-006770d5-63a7-44a9-88e6-233d86a4e0a6.png" alt="Gifty-5"/>
</div>

## Feature
1. 사진 앱에서 기프티콘 이미지를 모두 찾을 수 있습니다.
2. 기프티에서 삭제한 이미지가 갤러리에 바로 반영 돼 쓸 수 없는 이미지를 쉽게 관리할 수 있습니다.
3. 날짜를 기준으로 사진의 범위를 설정할 수 있어 원하는 만큼 스캔할 수 있습니다.

## Issues
> 너무 오래 걸리는 로딩

모든 사진 데이터를 SerialQueue로 불러오니 3000장 당 약 3분의 시간이 소요되었고,

만약 3만장의 사진이 있다면 30분이나 기다려야하는 이슈가 있었습니다.

```
[해결 방안]
먼저 Serial이 아닌 Concurrent Queue을 사용했습니다.
총 사진의 양을 3분할로 불러오게 수정해 기존에 3분 정도 걸리던 시간이 약 1분 정도로 줄어들었습니다.

그래도 3만장에 10분은 긴 시간이라 느껴졌기 때문에 최신순으로 몇 장의 사진을 검사할 지 선택할 수 있는 기능을 추가했습니다.
```

> 원하지 않는 바코드 사진

이미지를 스캔할 때 기프티콘만 뽑아오는 것을 기대했지만, 

바코드가 포함된 이미지면 모두 필터 돼 원하지 않는 다른 상품이 포함되는 이슈가 있었습니다.

```
[해결 방안]
바코드에 대한 사전 지식이 필요했습니다.
우리가 일반적으로 구매하는 물품에 표시된 바코드는 EAN13(국제 상품 번호) 규격을 따르고 있었고,
기프티콘이나 상품권 등에 쓰이는 바코드는 Code128 규격을 따르고 있다는 것을 확인했습니다.

이 점을 이용해 기존의 VNBarcodeSymbology가 검사하던 바코드 종류를 Code128로 명시해 문제를 해결했습니다.
```

## Stack
Swift, Storyboard, Lottie, Vision, PhotoKit

## Period
2021.09 ~ 
