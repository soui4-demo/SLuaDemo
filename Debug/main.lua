function onBtnClose(e)
	slog("onBtnClose");
	local hostWnd = GetHostWndFromObject(e:Sender());
	hostWnd:DestroyWindow();
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
	local slot = CreateEventSlot("onBtnClose");
	btnClose:SubscribeEvent(10000,slot);--10000 == EVT_CMD
	slot:Release();
	souiFac:Release();
	slog("main done");
	return theApp:Run(hostWnd:GetHwnd());
end

