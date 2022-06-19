---
title: "Sliding Window 解題筆記"
date: 2022-02-03T14:54:57+01:00
draft: false
categories:
    - CSIE
tags:
    - DSA
    - LeetCode
---

Sliding Window使用左右指針將搜尋區間固定住，最佳的應用例子是可以把搜尋的時間複雜度維持在線性。
實作上的基本概念就是在每次檢查針對題目要求更新window的大小。


## :rocket: 實例
這次選了兩道medium難度的題目，分別是 
#3 (Longest Substring Without Repeating Characters) 以及 
#438 (Find All Anagrams in a String)

### 3. Longest Substring Without Repeating Characters

找出字串`s`中最長的不重複子字串。舉例來說，
> * Input: s = "abcabcbb"
> * Output: 3
> * Input: s = "bbbbb"
> * Output: 1
> * Input: s = "pwwkew"
> * Output: 3
> * Input: s = "aab"
> * Output: 2
> * Input: s = "dvdf"
> * Output: 3
> * Input: s = "qrsvbspk"
> * Output: 5
> * Input: s = "aabaab!bb"
> * Output: 3

*(有這麼多例子，就是因為我實在錯太多次了QQ)*

#### 演算法概念

我們可以利用兩個pointer指向window的左邊端點與右邊端點，並以集合的方式來檢查是否window中有重複的元素。
* 如果沒有，就繼續把window擴大，同時取**最長子字串長度**len=max(set.size, len)。
* 有的話，window得更新範圍，與此同時，集合當中的元素也要更新。更新的方法其實就是如果有重複，就把==重複的元素當中比較舊的==那個給移除掉。
:::warning
要注意的是，不僅僅是將左端點s[l]刪除，假設今天s[r]是與s[l*]重複，那從s[l]到s[l*]的元素都要從集合中刪掉!!
:::


以上面第一個例子來演練一次的話，完整過程就會如下
```
s = "abcabcbb"
     lr        len=1(a)
     l r       len=2(a,b)
     l  r      len=3(a,b,c) -> 此時s[r]重複(a)，將左邊的a移除
s = "abcabcbb"
      l r      len=3(b,c,a)
      l  r     len=3(b,c,a) -> 此時s[r]重複(b)，將左邊的b移除
s = "abcabcbb"
       l r     len=3(c,a,b)
       l  r    len=3(c,a,b) -> 此時s[r]重複(c)，將左邊的c移除
s = "abcabcbb"
        l r    len=3(a,b,c)
        l  r   len=3(a,b,c) -> 此時s[r]重複(b)，將左邊的a,b移除
s = "abcabcbb"
          lr   len=3(c,b)
          l r  len=3(c,b) -> 此時s[r]重複(b)，將左邊的c,b移除
s = "abcabcbb"
            l
            r  len=3(b) *end*
```
*(放了很多次s字串，只是方便閱讀比對位置而已)*

#### 程式實作
驗證過概念上沒問題了之後，實作的C++程式如下
```cpp
int lengthOfLongestSubstring(string s) {
    set<char> chars;
    int l = 0, r = 1;

    chars.insert(s[l]);
    int len = chars.size();

    if (s.length() == 0)
        return 0;
    while (r < s.length()) {
        if (chars.find(s[r]) == chars.end()) {
            chars.insert(s[r]);
            len = chars.size() > len ? chars.size() : len;
            r += 1;
        } else { // remove all char before duplicated char
            while (s[l] != s[r]) {
                chars.erase(s[l]);
                l += 1;
            }
            chars.erase(s[l]);
            l += 1;
        }
    }
    return len;
}
```

### 438. Find All Anagrams in a String

提供兩個字串`s`、`p`，回傳所有符合`p`是`s`的anagram的index。
> Anagram意思指僅使用一次包含的所有字元的排列組合。如以下例子
Input: s = "cbaebabacd", p = "abc"
Output: [0,6]
[0-2]的"cba"是p的anagram，而[6-8]的"bac"也是p的anagram。

#### 演算法概念

一開始想到的方法，除了暴力法外，若想要把搜尋限制在線性，我想到可以用sliding window+數數的方法。
也就是說，因為在此題中，s, p限制了內容只會是小寫字母，因此我們可以直接使用一個map將26個字母的數量存起來。同樣的，使用l+r指標，框住目前的window，使用r指標依序檢查s[r]是否有在p map當中，有的話那就減一，但如果扣到<0，跟**p字串不存在這個字母**的情況一樣，那就移到下一個window檢查，也就是`l+=1`。

當p的這個map每個字母都扣完了，代表目前這個window就是我們要找的anagram。

#### 程式實作

pMap代表p字串中各個字母的數量。pTotal是pMap的總和，一開始pTotal==p.size()。
`pM`與`pT`是每個window的比較基準，因為每個符合的window都是anagram of p。`pM`與`pT`是從原本的pMap, pTotal copy過來的。

```cpp
vector<int> findAnagrams(string s, string p) {
    vector<int> indexs;

    if(s.size()==0)
        return indexs;

    int pMap[26] = {0};
    int pTotal=p.size();

    for(int i=0; i<p.size(); i++) {
        pMap[p[i]-'a']+=1;
    }

    int l=0, r=0;
    for(int l=0; l<s.size(); l++) {
        int r=l, pT=pTotal;
        int pM[26];
        memcpy(pM, pMap, 26*sizeof(int));

        while(r<s.size() && --pM[s[r]-'a']>=0) {
            pT-=1;
            if(pT==0) {
                indexs.push_back(l);
            }
            r+=1;
        }
    }

    return indexs;
}
```

## 小結

使用兩個題目來解釋sliding window的概念，希望能幫助到也感到困惑的人。也提醒自己不要忘了主要的重點：使用l,r固定住檢查範圍，在每次檢查針對題目要求更新window的大小。
