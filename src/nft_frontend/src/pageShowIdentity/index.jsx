import { useEffect, useState } from 'react';
import { Image, Toast } from '@nutui/nutui-react';
import { Link, useNavigate, useLocation } from 'react-router-dom'
import { ArrowLeft } from '@nutui/icons-react'
import { NavBar } from '@nutui/nutui-react'
import imgfadian from './assets/fadian.png';
import imgkongtou from './assets/kongtou.png';
import imgleidian from './assets/leidian.png';
import imgshandian from './assets/shandian.png';
import vector from './assets/vector.svg';
import queryString from 'query-string';
import copy from 'copy-to-clipboard'
import { nft_backend, createActor } from 'declarations/nft_backend';
import { AuthClient } from "@dfinity/auth-client"
import { HttpAgent } from "@dfinity/agent";
import { AccountIdentifier } from "@dfinity/ledger-icp";
import './index.css';


function Page() {

    const navigate = useNavigate()
    const [pageData, setPageData] = useState({});

    const data = [{
        key: '合约类型',
        value: 'nft_type'
    }, {
        key: '铸造时间',
        value: 'mint_time'
    }, {
        key: '公链（Layer1/2）',
        value: 'location'
    }, {
        key: 'VFT数量更新时间',
        value: 'vft_update_time'
    }]

    const ctime = (t) => {
        const date = new Date(t / 1000000);
        const Y = date.getFullYear() + '-';
        const M = (date.getMonth() + 1 < 10 ? '0' + (date.getMonth() + 1) : date.getMonth() + 1) + '-';
        const D = date.getDate() + ' ';
        const h = date.getHours() + ':';
        const m = date.getMinutes() + ':';
        const s = date.getSeconds();
        if (t) {
            return Y + M + D + h + m + s;
        } else {
            return '';
        }

    }

    const handleCopyClick = () => {
        try {
            if (pageData.vfans_account_id) copy(pageData.vfans_account_id)
            Toast.show('已复制到剪贴板')
        } catch {
            Toast.show({
                content: '复制失败',
                icon: 'fail',
            })
        }
    }

    useEffect(() => {
        (async () => {
            const params = queryString.parse(location.search);
            let id = params.id;
            if (!id) {
                // create an auth client
                let authClient = await AuthClient.create();
                // start the login process and wait for it to finish
                await new Promise((resolve) => {
                    authClient.login({
                        identityProvider: 'https://identity.ic0.app',
                        onSuccess: resolve,
                    });
                });

                // At this point we're authenticated, and we can get the identity from the auth client:
                const identity = authClient.getIdentity();
                // Using the identity obtained from the auth client, we can create an agent to interact with the IC.
                const agent = new HttpAgent({ identity });
                const actor = createActor('zfeoc-xaaaa-aaaal-ai4nq-cai', {
                    agent,
                });
                // Using the interface description of our webapp, we create an actor that we use to call the service methods.
                const principal = await actor.whoami();
                const textDecoder = new TextDecoder();
                const accountIdentifier = AccountIdentifier.fromPrincipal({ principal: principal })
                id = accountIdentifier.toHex();
            }
            console.log(id)
            nft_backend.queryNfts(id).then((data) => {
                console.log(data, '------')
                const d = JSON.parse(data);
                if (d.vft_update_time) {
                    d.vft_update_time = ctime(d.vft_update_time);
                }
                if (d.mint_time) {
                    d.mint_time = ctime(d.mint_time);
                }
                setPageData(d);
            });

        })()
    }, [])




    return (
        <div className='show-container'>
            <NavBar
                back={<ArrowLeft color="rgba(0, 0, 0, 0.85)" />}
                onBackClick={() => navigate(-1)}
            ></NavBar>
            <div style={{
                backgroundImage: `url(${imgfadian})`
            }} className='image-bg'>
                <div className='image-btn'>
                    <Link to={process.env.DFX_MORE_VFT}>
                        <span className='image-btn-link'>获取更多</span>
                    </Link>
                </div>
            </div>
            <div className='content'>
                <div className='input-label'>社区身份地址：</div>
                <div className='input-box'>
                    <div className='input-txt'>{pageData.vfans_account_id || '铸造中，请稍后查看'}</div>
                    <div onClick={handleCopyClick} style={{
                        backgroundImage: `url(${vector})`
                    }} className='vector'  ></div>
                </div>
                <div className='row-box'>
                    {
                        data.map((item, index) => {
                            return (<div className='row'>
                                <div className='row-lable'>{item.key}： </div>
                                <div className='row-value'>{pageData[item.value] || '铸造中，请稍后查看'}</div>
                            </div>)
                        })
                    }
                </div>
                <div className='block'>
                    <div className='block-title'>社区身份作用：</div>
                    <div className='block-txt'>
                        无法复制或转让的凭证，但可以存取您VFT的变动信息，未来也会包含您在社区的投票权重（声誉值）
                    </div>
                </div>
            </div>
        </div>
    );
}

export default Page;
