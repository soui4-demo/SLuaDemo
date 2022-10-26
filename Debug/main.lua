function onBtnClose(e)
	slog("onBtnClose");
	local hostWnd = GetHostWndFromObject(e:Sender());
	hostWnd:DestroyWindow();
end

function onLvBtnClick(e)
	slog("onLvBtnClick");

end

function lv_getView(strCtx, iPos, pItem, xmlTemplate)
	slog("lv_getView ipos:" .. iPos);
	if(pItem:GetChildrenCount() == 0) then
		pItem:InitFromXml(xmlTemplate);
	end
	local pTxt = pItem:FindChildByNameA("lv_txt1",-1);
	pTxt:SetWindowText(T("hello lua " .. iPos));
	local pBtn = pItem:FindChildByNameA("lv_btn1",-1);
	SubscribeWindowEvent(pBtn,10000,"onLvBtnClick");
end

function lv_getCount(strCtx)
	return 100;
end

function onBtnInitLv(e)
	slog("init listview");
	local hostWnd = GetHostWndFromObject(e:Sender());
	toSWindow(e:Sender());
	local lvTst = hostWnd:FindIChildByName(L"lv_test",-1);
	slog("init listview, FindIChildByName done");
	local ilvTst = QiIListView(lvTst);
	slog("init listview, QiIListView done");

	local adapter = CreateLvAdapter("test_lv");
	adapter:initCallback(0,"lv_getView");
	adapter:initCallback(1,"lv_getCount");

	slog("init listview, init callbacks done");
	ilvTst:SetAdapter(adapter);
	slog("init listview, SetAdapter done");
	adapter:Release();
	ilvTst:Release();
end

function main(hinst,strWorkDir,strArgs)
	slog("main start");
	local souiFac = CreateSouiFactory();
	local resProvider = souiFac:CreateResProvider(1);-- 1 = res_file
	InitFileResProvider(resProvider,strWorkDir .."\\uires");
	local theApp = GetApp();
	local resMgr = theApp:GetResProviderMgr();
	resMgr:AddResProvider(resProvider,T"uidef:xml_init");
	resProvider:Release();

	local hostWnd = souiFac:CreateHostWnd(T"LAYOUT:XML_MAINWND");
	local hwnd = GetActiveWindow();
	hostWnd:Create(hwnd,0,0,0,0);
	hostWnd:ShowWindow(1); --1==SW_SHOWNORMAL
	local btnClose = hostWnd:FindIChildByName(L"btn_close",-1);
	SubscribeWindowEvent(btnClose,10000,"onBtnClose");

	local btnInitLv = hostWnd:FindIChildByName(L"btn_init_lv",-1);
	SubscribeWindowEvent(btnInitLv,10000,"onBtnInitLv");
	
	souiFac:Release();
	
	slog("main done");
	return theApp:Run(hostWnd:GetHwnd());
end

