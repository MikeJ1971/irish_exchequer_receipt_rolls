xquery version "3.1";

declare namespace tei = 'http://www.tei-c.org/ns/1.0';
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "text";
declare option output:media-type "text/plain";

declare function local:to_pence($val) {

    let $shilling_as_pence := 12
    let $pound_as_pence := 20 * $shilling_as_pence
    let $mark_as_pence := ($shilling_as_pence * 13) + 4
    return
        (: check for marks :)
        if (fn:matches($val, "^(\d+|½)\smark(s?)$")) then
            let $tokens := fn:tokenize($val, "\s")
            return
                if ($tokens[1] eq '½') then
                    $mark_as_pence div 2
                else
                    fn:number($tokens[1]) * $mark_as_pence
        (: check for just pence :)
        else if (fn:matches($val, "^\d+d\.$")) then
            let $tmp := fn:substring-before($val, 'd.')
            return fn:number($tmp)
        (: check for just shillings :)
        else if (fn:matches($val, "^\d+s\.$")) then
            let $shilling_temp := fn:substring-before($val, 's.')
            return fn:number($shilling_temp) * $shilling_as_pence
        (: check for just pounds :)
        else if (fn:matches($val, "^£\d+$", "")) then
            let $pounds_temp := fn:substring-after($val,'£')
            return fn:number($pounds_temp) * $pound_as_pence
        (: check for shillings and pence :)
        else if (fn:matches($val, "^\d+s\.\d+d\.")) then
            let $shilling_temp := fn:replace($val, "s\.\d+d\.", '')
            let $pence_temp := fn:replace($val, "\d+s\.", '')
            let $pence := fn:substring-before($pence_temp, 'd.')
            return (fn:number($shilling_temp) * $shilling_as_pence) + fn:number($pence)
        (: check for pounds, shillings and pence :)
        else if (fn:matches($val, "^£\d+\.\d+s\.\d+d\.")) then
            (: get the £ :)
            let $pound_temp := fn:replace($val, "\.\d+s\.\d+d\.", '')
            let $pound_temp2 := fn:replace($pound_temp, '£', '')
            let $pound_val := fn:number($pound_temp2) * $pound_as_pence
            (: get the shilling :)
            let $shilling_temp := fn:replace($val, "^£\d+\.", '')
            let $shilling_temp2 := fn:replace($shilling_temp, 's\.\d+d\.$', '')
            let $shilling_val := fn:number($shilling_temp2) * $shilling_as_pence
            (: get d. :)
            let $pence_temp := fn:replace($val, "^£\d+\.\d+s\.", '')
            let $pence_temp2 := fn:substring-before($pence_temp, 'd.')
            let $pence_val := fn:number($pence_temp2)
            return $pound_val + $shilling_val + $pence_val
        else
            $val

};
("Date,Source,Value&#xa;"),
(
let $roll := fn:doc("E_101_233_16.xml")
let $days := $roll//tei:div[@type="membrane"]/tei:div/tei:div
for $day in $days
    let $date := $day/tei:head/tei:date/@when/string()
    let $sections := $day/tei:div
    for $section in $sections
        let $place := $section/tei:opener/string()
        let $entries := $section/tei:ab
        for $entry in $entries
            let $val := $entry//tei:measure[@type='currency'][1]/string()
            return concat(fn:normalize-space(fn:string-join(($date, $place, local:to_pence($val)), ',')), '&#10;')
)
