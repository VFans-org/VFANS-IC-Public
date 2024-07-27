import { useState, useEffect } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom'
import { nft_backend, createActor } from 'declarations/nft_backend';
import { AuthClient } from "@dfinity/auth-client"
import { HttpAgent } from "@dfinity/agent";
import { AccountIdentifier } from "@dfinity/ledger-icp";
import { NavBar, Loading, Overlay } from '@nutui/nutui-react'
import { ArrowLeft } from '@nutui/icons-react'
import queryString from 'query-string';
import CryptoJS from 'crypto-js';
import '@nutui/nutui-react/dist/style.css'

import './index.css';

function Page() {
    const navigate = useNavigate()
    const localtion = useLocation()
    const params = queryString.parse(location.search);
    const [suid, setSuid] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    // const [error, setError] = useState(null);

    const encryptData = (data, secretKey) => {
        const encryptedData = CryptoJS.AES.encrypt(data, secretKey).toString();
        return encryptedData;
    }

    const decryptData = (encryptedData, secretKey) => {
        const bytes = CryptoJS.AES.decrypt(encryptedData, secretKey);
        const originalData = bytes.toString(CryptoJS.enc.Utf8);
        return originalData;
    }

    const onCreateTest = () => {
        console.log(params, 'aa')
        params.id = 'aaa';
        console.log(queryString.stringify(params), 'bb', localtion);
    }

    async function onCreate(event) {
        event.preventDefault();

        // create an auth client
        let authClient = await AuthClient.create();
        // start the login process and wait for it to finish
        await new Promise((resolve) => {
            authClient.login({
                identityProvider: 'https://identity.ic0.app',
                onSuccess: resolve,
            });
        });
        setIsLoading(true);
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
        // alert(accountIdentifier.toHex());
        console.log(accountIdentifier.toHex());

        params.id = accountIdentifier.toHex();
        console.log(queryString.stringify(params), 'bb');

        console.log(suid, accountIdentifier.toHex(), 'ids');

        nft_backend.binding_vfans(suid, accountIdentifier.toHex())
            .then((data) => {
                console.log(data, 'binding_vfans------')
                setIsLoading(false);
                // 页面跳转
                navigate('/pageShowIdentity?' + queryString.stringify(params));
            });
        return false;
    }

    useEffect(() => {
        const encryptedData = params.u;
        if(encryptedData && encryptedData!=''){
            console.log('encryptedData', encryptedData)
            const secretKey = 'vfansvfans';
            const decryptedData = decryptData(encryptedData, secretKey);
            console.log('decryptedData', decryptedData)
            setSuid(decryptedData);
        }
        
    }, []);


    const WrapperStyle = {
        display: 'flex',
        height: '100%',
        alignItems: 'center',
        justifyContent: 'center'
    }


    return (
        <div className='page-getid'>

            <Overlay visible={isLoading}>
                <div className="wrapper" style={WrapperStyle}>
                    <Loading direction="vertical">加载中</Loading>
                </div>
            </Overlay>
            <NavBar
                back={<ArrowLeft color="rgba(0, 0, 0, 0.85)" />}
                onBackClick={() => navigate(-1)}
            ></NavBar>
            <div className='getid-content'>
                <div className='getid-block-box'>
                    <div className='getid-block'>
                        <div className='getid-block-title'>
                            说明：
                        </div>
                        <div className='getid-block-txt'>
                            1、该链上ID来源于 Internet Identity，更多链开发中，敬请期待
                        </div>
                        <div className='getid-block-txt'>
                            2、链上ID成功获取后，将进入NFT自动铸造流程，稍后可重新进入页面查看
                        </div>
                    </div>
                </div>
                <div className='link-box'>
                    <Link className='link' to={process.env.DFX_SHOW_TUTO}>
                        <span className='link'>点击查看创建教程</span>
                    </Link>

                </div>
                <div className='btn-box'>
                    <span onClick={onCreate} className='btn'>去创建</span>
                </div>
                {/* <div className='btn-box'>
                    <span onClick={onCreateTest} className='btn'>测试</span>
                </div> */}
            </div>

        </div>
    );
}

export default Page;
