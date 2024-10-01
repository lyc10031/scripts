import http.client
import random
import time


def call():
    conn = http.client.HTTPSConnection('app.bilibili.com')
    headers = {
        'accept': '*/*',
        'accept-language': 'zh-CN,zh;q=0.9',
        'content-type': 'application/x-www-form-urlencoded',
        'cookie': "buvid3=7D2FED78-2ABD-5486-26C5-B62BA481D2AE67078infoc; b_nut=1718610067; _uuid=4EB6E110D-684B-1181-5DB3-FB885536D10BD67274infoc; buvid4=2DF92231-4D0E-8976-50DC-D390672CD04B67973-024061707-VL%2FInh8s8YzVYkyOwrpSiA%3D%3D; DedeUserID=4698795; DedeUserID__ckMd5=9d5730a21a2c9f7a; header_theme_version=CLOSE; enable_web_push=DISABLE; is-2022-channel=1; CURRENT_FNVAL=4048; rpdid=|(k|~u~lm~Yk0J'u~kl||k)~m; buvid_fp_plain=undefined; hit-dyn-v2=1; bsource=search_bing; home_feed_column=5; browser_resolution=1440-812; b_lsid=687F53FB_192482B7F9A; bili_ticket=eyJhbGciOiJIUzI1NiIsImtpZCI6InMwMyIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MjgwNDY4NjYsImlhdCI6MTcyNzc4NzYwNiwicGx0IjotMX0.MD1EOFSo2gJVUPJvvXXHOqZQx7GkrNv6RXiDrWf_C40; bili_ticket_expires=1728046806; SESSDATA=80498baf%2C1743339668%2C9e084%2Aa2CjCrdd_ZUzpxBlBgTjGDUYFJh41T97TPh_Ykg90WzGQp1ztpoS6-luDcMMkwUzlCzHESVlpBUW1qU0hIQ2l3Uk8tMEFlc2IxQXFUMWFKU2s5eV9VaERtSVdGY1pTMllOUUQ5Sm9rTlR2alZzcjFRbmg5Rmk4amJkOVNsTE9VZ0EtTmkxcm92Tmt3IIEC; bili_jct=aaac0c5286d027454d31f2ff4304b081; sid=dw6tqgam; bp_t_offset_4698795=983329631388041216; fingerprint=1fa1aa3a163bb6befa8e90692d69864e; msource=pc_web; deviceFingerprint=8dd59b48ea103a1ef850244872f2ebb1; buvid_fp=1fa1aa3a163bb6befa8e90692d69864e",
        'origin': 'https://www.bilibili.com',
        'priority': 'u=1, i',
        'referer': 'https://www.bilibili.com/blackboard/activity-new-freedata.html',
        'sec-ch-ua': '"Google Chrome";v="129", "Not=A?Brand";v="8", "Chromium";v="129"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"macOS"',
        'sec-fetch-dest': 'empty',
        'sec-fetch-mode': 'cors',
        'sec-fetch-site': 'same-site',
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36',
    }
    conn.request(
        'POST',
        '/x/wall/unicom/order/pack/receive_v2',
        'cross_domain=true&id=3&csrf=aaac0c5286d027454d31f2ff4304b081',
        headers
    )
    response = conn.getresponse()
    # 输出响应数据
    res = response.read().decode('utf-8')
    print(res)
    conn.close()
    return res



if __name__ == '__main__':
    while True:
        if time.strftime('%Y-%m-%d %H:%M:%S', time.localtime()) == '2024-10-01 23:59:59':
            for i in range(10):
                print(f"第{i+1}次调用 时间：{time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())}")
                resp = call()
                if '{"code":78127,"message":"78127"}' != resp:
                    print("抢到了，停止抢")
                    break
                else:
                    print("没抢到继续抢～")
                # 随机等待50到500毫秒
                wait_time = random.randint(50, 500) / 1000
                time.sleep(wait_time)
        else:
            time.sleep(1)
            # 输出当前时间
            print(f"执行时间未到，当前时间：{time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())}")

