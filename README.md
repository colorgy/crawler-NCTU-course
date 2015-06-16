交大課程爬蟲
=========
https://timetable.nctu.edu.tw/

# TODOS
* 把 API class 弄成 gem 釋出。
* 串 search API

# 喇賽

既然是一個工整的 API，那有個 API wrapper 也不為過了吧 Zzz
於是就來包裝吧！


```json
{
  "0UN": {
    "dep_id": "0UN",
    "dep_cname": "課務組",
    "dep_ename": null,
    "1": {
      "1032_0001": {
        "acy": "103",
        "sem": "2",
        "cos_id": "0001",
        "cos_code": "DOA4999",
        "num_limit": "9999",
        "dep_limit": "*",
        "URL": null,
        "cos_cname": "領袖學程專題講解",
        "cos_credit": "0",
        "cos_hours": "0",
        "TURL": " ",
        "teacher": "陳清和",
        "cos_time": "4IJ-A302",
        "memo": " ",
        "cos_ename": "Lecture of Topics on leadership and Group Learning",
        "brief": " ",
        "degree": "0",
        "dep_id": "UN",
        "dep_primary": "1",
        "dep_cname": "課務組",
        "dep_ename": null,
        "cos_type": "選修",
        "cos_type_e": "Elective",
        "crsoutline_type": null,
        "reg_num": "0",
        "depType": "O"
      }
    }
  }
}
```
最外層 deparment key，再來是「其他相關教學單位課程」"1" 或是該系課程表 "2"，接下來就是 `year+term-serial` 組合，恩恩我也這樣實作。剩下來就直接解啦。

Try 了一下，POST data 也是輕鬆如意：

*`POST timetable.nctu.edu.tw/?r=main/get_cos_list`*

```
    m_acy:103
    m_sem:2
    m_degree:2
    m_dep_id:41
    m_group:**
    m_grade:**
    m_class:**
    m_option:**
    m_crsname:**
    m_teaname:**
    m_cos_id:**
    m_cos_code:**
    m_crstime:**
    m_crsoutline:**
```
非常明顯就是在 `m_degree` 和 `m_dep_id` 的組合而已。這邊就利用其 API 把所有組合套出來便是。
