/*
    Fonksiyon: TC2_fnc_uiReleaseFocus
    Çalışma yeri: İstemci (terminal ve pilot pencerelerinin "MouseButtonDown" olayı)

    Sorun: yazı kutusuna (RscEdit) tıklanınca klavye odağı kutuda kalıyor ve başka yere tıklamak zorlaşıyordu.
    Çözüm: sol tık, herhangi bir GÖRÜNÜR yazı kutusunun DIŞINDAYSA odağı zararsız bir düğmeye ver
    (terminalde o anki sekmenin düğmesi: Enter/Boşluk yalnızca aynı sekmeyi tekrar seçer; pilot penceresinde GERİ OKU).
    Tıklama yazı kutusunun içindeyse hiçbir şey yapılmaz (kutu odağı normal alır).

    Parametreler:
        0: pencere <DISPLAY>
        1: fare x <NUMBER>
        2: fare y <NUMBER>
        3: yazı kutusu IDC listesi <ARRAY>
        4: odak verilecek düğme IDC <NUMBER>

    Dönüş: yok
*/

params ["_display", "_mx", "_my", "_editIdcs", "_focusIdc"];

private _inside = false;

{
    private _control = _display displayCtrl _x;
    if (!isNull _control && {ctrlShown _control}) then {
        (ctrlPosition _control) params ["_cx", "_cy", "_cw", "_ch"];
        if (_mx >= _cx && {_mx <= _cx + _cw} && {_my >= _cy} && {_my <= _cy + _ch}) then {_inside = true};
    };
} forEach _editIdcs;

if (!_inside) then {
    ctrlSetFocus (_display displayCtrl _focusIdc);
};
