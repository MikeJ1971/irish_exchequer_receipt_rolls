def convert_pennies(total):

    shilling_as_pence = 12
    pound_as_pence = 20 * shilling_as_pence

    pound, pence_r = divmod(total, pound_as_pence)
    shilling, pence = divmod(pence_r, shilling_as_pence)

    pound_val = "£{}.".format(pound) if pound > 0 else ""
    shilling_val = "{}s.".format(shilling) if shilling > 0 else ""
    pence_val = "{}d.".format(pence) if pence > 0 else ""

    return pound_val + shilling_val + pence_val
