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

listview_count = 1000;

function lv_getView(strCtx, iPos, pItemPanel, xmlTemplate)
	local pItem = pItemPanel;
	local nChilds = pItem:GetChildrenCount();
	if(nChilds == 0) then
		pItem:InitFromXml(xmlTemplate);
	end
	local pTxt = pItem:FindIChildByNameA("lv_txt1",-1);
	pTxt:SetWindowText(T("hello lua " .. iPos));
	local pBtn = pItem:FindIChildByNameA("lv_btn1",-1);
	LuaConnect(pBtn,10000,"onLvBtnClick");
end

function lv_getCount(strCtx)
	return listview_count;
end

function initListview(hostWnd)
	slog("init listview");
	local lvTst = hostWnd:FindIChildByName(L"lv_test",-1);
	local ilvTst = QiIListView(lvTst);

	local adapter = CreateLvAdapter(100);--100 as the context id for the listview
	adapter:initCallback(0,"lv_getView");
	adapter:initCallback(1,"lv_getCount");

	ilvTst:SetAdapter(adapter);
	adapter:Release();
	ilvTst:Release();
end

function onBtnResetLv(e)
	slog("onBtnResetLv");
	local hostWnd = GetHostWndFromObject(e:Sender());
	local lvTst = hostWnd:FindIChildByName(L"lv_test",-1);
	local ilvTst = QiIListView(lvTst);
	local adapter = ilvTst:GetAdapter();
	local luaAdapter = toLuaLvAdapter(adapter); -- cast from ILvAdapter to LuaLvAdapter
	slog("list view context =" .. luaAdapter:getContext());
	listview_count = 5;
	luaAdapter:notifyDataSetChanged();
	ilvTst:Release();
end

function onBtnMenu(e)
	slog("onBtnMenu");
	local hostWnd = GetHostWndFromObject(e:Sender());
	local btn = toSWindow(e:Sender());
	local souiFac = CreateSouiFactory();
	local menu = souiFac:CreateMenu(0);
	souiFac:Release();
	menu:LoadMenu(T"smenu:menu_test");
	local rcBtn = btn:GetWindowRect2();
	SClientToScreen(hostWnd,rcBtn);
	local cmd = TrackPopupIMenu(menu,0x100,rcBtn.left,rcBtn.bottom,100); --ox100 == TPM_RETURNCMD
	menu:Release();
	slog("cmd ret ".. cmd);
end

function onBtnMenuEx(e)
	slog("onBtnMenuEx");
	local hostWnd = GetHostWndFromObject(e:Sender());
	local btn = toSWindow(e:Sender());
	local souiFac = CreateSouiFactory();
	local menu = souiFac:CreateMenuEx();
	souiFac:Release();
	menu:LoadMenu(T"smenu:menuex_test");
	local rcBtn = btn:GetWindowRect2();
	SClientToScreen(hostWnd,rcBtn);
	local cmd = TrackPopupIMenuEx(menu,0x100,rcBtn.left,rcBtn.bottom,100); --ox100 == TPM_RETURNCMD
	menu:Release();
	slog("cmd ret ".. cmd);
end

function onSlidePos(e)
	local data=toStEventSliderPos(e:Data());
	local hostWnd = GetHostWndFromObject(e:Sender());
	local txt = hostWnd:FindIChildByNameA("txt_pos",-1);
	txt:SetWindowText(T("".. data.nPos));
end

function onBtnInitTreectrl(e)
	slog("onBtnInitTreectrl");
	local hostWnd = GetHostWndFromObject(e:Sender());
	local treeWnd = hostWnd:FindIChildByName(L"tree_test",-1);
	local treeCtrl = QiITreeCtrl(treeWnd);
	treeCtrl:RemoveAllItems();
	local item1= treeCtrl:InsertItem(T"hello",0,1,100,0xffff0000,0xffff0002); --0xffff0000 == STVI_ROOT, 0xffff0002==STVI_LAST
	treeCtrl:InsertItem(T"lua",0,1,100,item1,0xffff0002);
end

function onBtnDialog(e)
	slog("onBtnDialog");
	local btnSender = toSWindow(e:Sender());
	local hParent = btnSender:GetHostHwnd();
	local souiFac = CreateSouiFactory();
	local dialog = souiFac:CreateHostDialog(T"layout:dlg_test");
	souiFac:Release()
	local ret = dialog:DoModal(hParent);
	dialog:Release();
end

function on_toggle(e)
    slog("on toggle");
    local hostWnd = GetHostWndFromObject(e:Sender());
	local leftPane = hostWnd:FindIChildByName(L"pane_left",-1);

    local toggle = toSWindow(e:Sender());
    local isChecked = toggle:IsChecked();
    local theApp = GetApp();
    local anim;
    if(isChecked == 1) then
        slog("on toggle true".. isChecked);
        anim = theApp:LoadAnimation(T"anim:slide_show");
    else
        slog("on toggle false".. isChecked);
        anim = theApp:LoadAnimation(T"anim:slide_hide");
    end
    leftPane:SetAnimation(anim);
    anim:Release();
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

	local hostWnd = souiFac:CreateHostWnd(T"LAYOUT:dlg_main");
	local hwnd = GetActiveWindow();
	hostWnd:Create(hwnd,0,0,0,0);
	hostWnd:ShowWindow(1); --1==SW_SHOWNORMAL
	initListview(hostWnd);

	local btnClose = hostWnd:FindIChildByNameA("btn_close",-1);
	LuaConnect(btnClose,10000,"onBtnClose"); --10000 == EVT_CMD

	local btnMax = hostWnd:FindIChildByNameA("btn_max",-1);
	LuaConnect(btnMax,10000,"onBtnMax");
	
	local btnRestore = hostWnd:FindIChildByNameA("btn_restore",-1);
	LuaConnect(btnRestore,10000,"onBtnRestore");

	local btnMin = hostWnd:FindIChildByNameA("btn_min",-1);
	LuaConnect(btnMin,10000,"onBtnMin");

	local btnMenu = hostWnd:FindIChildByNameA("btn_menu",-1);
	LuaConnect(btnMenu,10000,"onBtnMenu");

	local btnMenuEx = hostWnd:FindIChildByNameA("btn_menuex",-1);
	LuaConnect(btnMenuEx,10000,"onBtnMenuEx");

	local btnResetLv = hostWnd:FindIChildByNameA("btn_reset_lv",-1);
	LuaConnect(btnResetLv,10000,"onBtnResetLv");
	
	local btnInitTreeCtrl = hostWnd:FindIChildByNameA("btn_init_treectrl",-1);
	LuaConnect(btnInitTreeCtrl,10000,"onBtnInitTreectrl");

	local slider = hostWnd:FindIChildByNameA("tst_slider",-1);
	LuaConnect(slider,17000,"onSlidePos");--17000==EVT_SLIDERPOS

	local btnDialog = hostWnd:FindIChildByNameA("btn_dialog",-1);
	LuaConnect(btnDialog,10000,"onBtnDialog");

	local btnSwitch = hostWnd:FindIChildByNameA("tgl_left",-1);
	LuaConnect(btnSwitch,10000,"on_toggle");

	souiFac:Release();
	
	slog("main done");
	return theApp:Run(hostWnd:GetHwnd());
end

