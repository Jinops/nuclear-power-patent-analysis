# nuclear-power-patent-analysis

Patent Analysis on Nuclear Power using a Topic Model.

토픽모델을 이용한 한국의 원전 기술 특허 분석

![thumbnail](/img_graph.png)


## 목적

1. 2017년(탈원전 정책) 이후 한국 원전 기술 관련 특허를 파악하고 평가합니다.
2. 미국 특허청에 등록된 한국 및 상위 5개국의 특허를 비교합니다.
3. 특허의 추이 파악 및 방향성을 제시합니다.

## 데이터
- 미국 특허청의 [PatentsView](https://patentsview.org/)를 통해 특허 출원/등록 데이터 수집

## 주요 기능
1. 원전 관련 class와 sub class로 데이터 분리
2. 상위 5개국의 특허 출원/등록 수 그래프화
3. 특허들의 제목, 초록으로 토픽 모델 생성
4. 해당 모델과 년도, 국가 등의 상관관계를 회귀분석

## 회귀식
![regression](/img_regression.jpg)
