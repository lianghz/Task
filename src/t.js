import md5 from 'md5';

const testUserInfo = {
    appId:'fd88e9d193e2f62205',
    companyId: '100870388405',
    memberName: '张三',
    thrid: '20230505001',
};

console.log(md5(JSON.stringify(testUserInfo))); 

