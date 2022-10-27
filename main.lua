function onBtnClose(e)
	slog("onBtnClose");
	local hostWnd = GetHostWndFromObject(e:Sender());
	hostWnd:DestroyWindow();
	PostQuitMessage();
end

function onBtnMin(e)
	slog("onBtnMin");
	local hostWnd = GetHostWndFromObject(e:Sender());
	hostWnd:SendMessage(0x112,0xf020); 
end

function onBtnRestore(e)
	slog("onBtnRestore");
	local hostWnd = GetHostWndFromObject(e:Sender());
	local btnMax = hostWnd:FindIChildByNameA("btn_max",-1);
	local btnRestore = hostWnd:FindIChildByNameA("btn_restore",-1);
	btnMax:SetVisible(1,1);
	btnRestore:SetVisible(0,1);
	hostWnd:SendMessage(0x112,0xf120); 
end

function onBtnMax(e)
	slog("onBtnMax");
	local hostWnd = GetHostWndFromObject(e:Sender());
	local btnMax = hostWnd:FindIChildByNameA("btn_max",-1);
	local btnRestore = hostWnd:FindIChildByNameA("btn_restore",-1);
	btnMax:SetVisible(0,1);
	btnRestore:SetVisible(1,1);
	hostWnd:SendMessage(0x112,0xf030); 
end

function onLvBtnClick(e)
	slog("onLvBtnClick");
	local pBtn = toSWindow(e:Sender());
	local pRoot = pBtn:GetIRoot();
	local iPanel = QiIItemPanel(pRoot);
	local index = iPanel:GetItemIndex();
	SMessageBox(GetActiveWindow(),T("you had clicked " .. index .."item"),T"soui lua",0);
end

function lv_getView(strCtx, iPos, pItemPanel, xmlTemplate)
	slog("lv_getView ipos:" .. iPos);
	local pItem = pItemPanel;
	local nChilds = pItem:GetChildrenCount();
	slog("lv_getView GetChildrenCount done");
	if(nChilds == 0) then
		pItem:InitFromXml(xmlTemplate);
		slog("lv_getView InitFromXml done");
	end
	local pTxt = pItem:FindIChildByNameA("lv_txt1",-1);
	pTxt:SetWindowText(T("hello lua " .. iPos));
	local pBtn = pItem:FindIChildByNameA("lv_btn1",-1);
	LuaConnect(pBtn,10000,"onLvBtnClick");
end

function lv_getCount(strCtx)
	return 1000;
end

function onBtnInitLv(e)
	slog("init listview");
	local hostWnd = GetHostWndFromObject(e:Sender());
	toSWindow(e:Sender());
	local lvTst = hostWnd:FindIChildByName(L"lv_test",-1);
	local ilvTst = QiIListView(lvTst);

	local adapter = CreateLvAdapter(100);--100 as the context id for the listview
	adapter:initCallback(0,"lv_getView");
	adapter:initCallback(1,"lv_getCount");

	ilvTst:SetAdapter(adapter);
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
	local btnClose = hostWnd:FindIChildByNameA("btn_close",-1);
	LuaConnect(btnClose,10000,"onBtnClose"); --10000 == EVT_CMD

	local btnMax = hostWnd:FindIChildByNameA("btn_max",-1);
	LuaConnect(btnMax,10000,"onBtnMax");
	
	local btnRestore = hostWnd:FindIChildByNameA("btn_restore",-1);
	LuaConnect(btnRestore,10000,"onBtnRestore");

	local btnMin = hostWnd:FindIChildByNameA("btn_min",-1);
	LuaConnect(btnMin,10000,"onBtnMin");

	local btnInitLv = hostWnd:FindIChildByNameA("btn_init_lv",-1);
	LuaConnect(btnInitLv,10000,"onBtnInitLv");

	souiFac:Release();
	
	slog("main done");
	return theApp:Run(hostWnd:GetHwnd());
end

