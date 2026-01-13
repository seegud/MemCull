package top.seegood.memcull

import android.app.Application
import com.baidu.mobstat.StatService

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        
        // 通过该接口可以控制敏感数据采集，true表示可以采集，false表示不可以采集，
        // 该方法一定要最优先调用，请在StatService.autoTrace(Context context)
        // 之前调用，建议有用户隐私策略弹窗的App，用户未同意前设置false,同意之后设置true
        // 这里默认设置为 true，实际项目中应根据用户隐私协议勾选情况设置
        StatService.setAuthorizedState(this, true)
        
        // 自动埋点，建议在Application中调用。否则可能造成部分页面遗漏，无法完整统计。
        StatService.autoTrace(this)
    }
}
