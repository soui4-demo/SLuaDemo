// dui-demo.cpp : main source file
//

#include "stdafx.h"
#ifdef _DEBUG
#define SYS_NAMED_RESOURCE _T("soui-sys-resourced.dll")
#else
#define SYS_NAMED_RESOURCE _T("soui-sys-resource.dll")
#endif
#ifndef DLL_SOUI_COM
#ifdef _DEBUG
#pragma comment(lib,"scriptmodule-luad")
#else
#pragma comment(lib,"scriptmodule-lua")
#endif
#endif

using namespace SOUI;


void SetDefaultDir()
{
	TCHAR szCurrentDir[MAX_PATH] = { 0 };
	GetModuleFileName(NULL, szCurrentDir, sizeof(szCurrentDir));

	LPTSTR lpInsertPos = _tcsrchr(szCurrentDir, _T('\\'));
	_tcscpy(lpInsertPos + 1, _T("\0"));
	SetCurrentDirectory(szCurrentDir);
}

SApplication * InitApp(SComMgr & comMgr,HINSTANCE hInstance){
	SAutoRefPtr<IRenderFactory> pRenderFactory;
	SApplication * pRet = NULL;
	BOOL bLoaded = TRUE;
	do{
		bLoaded = comMgr.CreateRender_GDI((IObjRef * *)& pRenderFactory);
		SASSERT_FMT(bLoaded, _T("load interface [render] failed!"));
		if(!bLoaded) break;
		SAutoRefPtr<IImgDecoderFactory> pImgDecoderFactory;
		bLoaded = comMgr.CreateImgDecoder((IObjRef * *)& pImgDecoderFactory);
		SASSERT_FMT(bLoaded, _T("load interface [%s] failed!"), _T("imgdecoder"));
		if(!bLoaded) break;

		pRenderFactory->SetImgDecoderFactory(pImgDecoderFactory);
		pRet = new SApplication(pRenderFactory, hInstance);	
	}while(false);
	return pRet;
};

BOOL LoadSystemRes(SApplication *theApp,SouiFactory & souiFac)
{
	HMODULE hModSysResource = LoadLibrary(SYS_NAMED_RESOURCE);
	if (!hModSysResource)
		return FALSE;

	IResProvider* sysResProvider = souiFac.CreateResProvider(RES_PE);
	sysResProvider->Init((WPARAM)hModSysResource, 0);
	theApp->LoadSystemNamedResource(sysResProvider);
	sysResProvider->Release();
	FreeLibrary(hModSysResource);
	return TRUE;
}

BOOL LoadLUAModule(SApplication *theApp,SComMgr & comMgr)
{
	BOOL bLoaded =FALSE;
	SAutoRefPtr<IScriptFactory> pScriptLuaFactory;
	bLoaded = comMgr.CreateScrpit_Lua((IObjRef * *)& pScriptLuaFactory);
	SASSERT_FMT(bLoaded, _T("load interface [%s] failed!"), _T("scirpt_lua"));
	theApp->SetScriptFactory(pScriptLuaFactory);
	return bLoaded;
}

int WINAPI _tWinMain(HINSTANCE hInstance, HINSTANCE /*hPrevInstance*/, LPTSTR lpstrCmdLine, int /*nCmdShow*/)
{
	HRESULT hRes = OleInitialize(NULL);
	SASSERT(SUCCEEDED(hRes));
	SetDefaultDir();
	int nRet = 0;
	{
		SouiFactory souiFac;
		SComMgr comMgr;
		SApplication *theApp = InitApp(comMgr,hInstance);
		LoadSystemRes(theApp,souiFac);//load system resource
		LoadLUAModule(theApp,comMgr); //load lua script module.
		{
			SAutoRefPtr<IScriptModule> script;
			theApp->CreateScriptModule(&script); //create a lua instance
			script->executeScriptFile("main.lua");//load lua script
			TCHAR szDir[MAX_PATH];
			GetCurrentDirectory(MAX_PATH,szDir);
			SStringA strDir = S_CT2A(szDir);
			nRet = script->executeMain(hInstance,strDir.c_str(),NULL);//execute the main function defined in lua script
		}
		theApp->Release();
	}
	OleUninitialize();
	return nRet;
}
