function on_init(e)
    slog("on test dialog init");
end

function on_exit(e)
    slog("on test dialog exit");
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